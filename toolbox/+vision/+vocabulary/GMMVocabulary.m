classdef GMMVocabulary < handle & vision.vocabulary.GenericVocabulary
% GMMVocabulary Generate visual words vocabulary using GMM
%
%   Options:
%
%   'descount_limit':: 1e6
%     Maximum number of features to be use for clustering. Set to > 1
%     applies no discount.
%
%   'trainimage_limit':: -1
%     Maximum number of images to be use for clustering. Set to > 1 applies
%     no discount.
%
%   'voc_size':: 1000
%     Number of visual words in the visual vocabulary.
%
%   'GMM_init':: 'rand'
%     GMM initialisation method
    
    properties
        gmmConfiguration = struct(...
            'descount_limit', 1e6,...
            'trainimage_limit', -1,...
            'voc_size', 256,...
            'GMM_init', 'rand')
    end
    
    properties (Constant, Hidden)
        initType = {'rand', 'kmeans'};
    end
    
    methods
        function obj = GMMVocabulary(varargin)
            obj.gmmConfiguration = vl_argparse(obj.gmmConfiguration,varargin);
            
            assert(ismember(obj.gmmConfiguration.GMM_init, obj.initType), 'Initial means (GMM_init) must be set either on ''kmeans'' or ''rand''');
            % maximum number of comparisons when using ANN (-1 = exact)
            obj.gmmConfiguration.maxcomps = ceil(obj.gmmConfiguration.voc_size/4);
        end
        
        function vocabulary = trainVocabulary(obj, dataset, featureExtractor, varargin)

            % -------------------------------------------------------------------------
            % 1. Extract features for training into 'feats' matrix
            %     applying any limits on number of features/images
            % -------------------------------------------------------------------------
            
            % varargin contains image or concept lists, to be input to the getImagesPaths method from the
            % dataset class, to allow the vocabulary be prepared on a subset of images
            imagesPaths = dataset.getImagesPaths(varargin{:});
            
            % if trainimage_count was not left at it's default value
            % (indicating all detected images should be used for training)
            % select a subset of the images
            if obj.gmmConfiguration.trainimage_limit > 0
                idxs = 1:length(imagesPaths);
                idxs = vl_colsubset(idxs, obj.gmmConfiguration.trainimage_limit);
                imagesPaths = imagesPaths(idxs);
            end
            
            if obj.gmmConfiguration.descount_limit > 0
                % set truncation value for image features just a little bit
                % larger than descount_limit, so if there are any images
                % with fewer than descount_limit/numImages we still have
                % some chance of getting descount_limit descriptors in the end
                img_descount_limit = ceil(obj.gmmConfiguration.descount_limit / ...
                    length(imagesPaths) * 1.1);
                % fprintf('Extracting a maximum of %d features from each image...\n', ...
                %     img_descount_limit);
            else
                img_descount_limit = [];
            end
            
            feats = cell(length(imagesPaths),1);
            
            % setting for progress bar graphics and variables
            pfImcount = length(imagesPaths);
            text = 'Computing vocabulary features: ';
            barColor = [0.96 0.35 0.12];
            waitBar = helpers.graphics.WaitBar(pfImcount, text, barColor);
            
            % iterate through images, computing features
            % parfor ii = 1:pfImcount
            for ii = 1:pfImcount
                % fprintf('Computing features for: %s %f %% complete\n', ...
                %     imagesPaths{ii}, ii/pfImcount*100.00);
                
                % handle for cancel button on progress bar
                if ~waitBar.textualVersion && getappdata(waitBar.bar,'canceling')
                    fprintf('Not available now.\n');
                end
                
                % updates waitbar
                % waitBar.update(pfImcount-ii+1); % parfor version
                waitBar.update(ii);
                
                im = imread(imagesPaths{ii});
                im = featureExtractor.standardizeImage(im);
                feats_all = featureExtractor.compute(im);
                
                % if a descount limit applies, discard a fraction of features now to
                % save memory
                if obj.gmmConfiguration.descount_limit > 0
                    feats{ii} = vl_colsubset(feats_all, ...
                        img_descount_limit);
                else
                    feats{ii} = feats_all;
                end
            end
                        
            clear waitBar feats_all;
            % concatenate features into a single matrix
            feats = cat(2, feats{:});
            
            extractedFeatCount = size(feats,2);
            % fprintf('%d features extracted\n', extractedFeatCount);
            
            if obj.gmmConfiguration.descount_limit > 0
                % select subset of features for training
                feats = vl_colsubset(feats, obj.gmmConfiguration.descount_limit);
                % output status message
                % fprintf('%d features will be used for training of codebook (%f %%)\n', ...
                %     obj.gmmConfiguration.descount_limit, obj.gmmConfiguration.descount_limit/extractedFeatCount*100.0);
            end
            
            % -------------------------------------------------------------------------
            % 2. Cluster codebook centres
            % -------------------------------------------------------------------------
            
            if isequal(obj.gmmConfiguration.GMM_init, 'kmeans')
                
                fprintf('Computing initial means using K-means...\n');
                
                % if maxcomps is below 1, then use exact kmeans, else use approximate
                % kmeans with maxcomps number of comparisons for distances
                if obj.gmmConfiguration.maxcomps < 1
                    init_mean = vl_kmeans(feats, obj.gmmConfiguration.voc_size, ...
                        'verbose', 'algorithm', 'elkan');
                else
                    init_mean = vision.vocabulary.helpers.annkmeans(feats, obj.gmmConfiguration.voc_size, ...
                        'verbose', false, 'MaxNumComparisons', obj.gmmConfiguration.maxcomps, ...
                        'MaxNumIterations', 150);
                end
                
                fprintf('Computing initial variances and coefficients...\n');
                
                % compute hard assignments
                kd_tree = vl_kdtreebuild(init_mean, 'numTrees', 3) ;
                assign = vl_kdtreequery(kd_tree, init_mean, feats);
                
                % mixing coefficients
                init_coef = single(vl_binsum(zeros(obj.gmmConfiguration.voc_size, 1), 1, double(assign)));
                init_coef = init_coef / sum(init_coef);
                
                % variances
                init_var = zeros(size(feats, 1), obj.gmmConfiguration.voc_size, 'single');
                
                for i = 1:obj.gmmConfiguration.voc_size
                    feats_cluster = feats(:, assign == i);
                    init_var(:, i) = var(feats_cluster, 0, 2);
                end
                
            elseif isequal(obj.gmmConfiguration.GMM_init, 'rand')
                init_mean = [];
                init_var = [];
                init_coef = [];
            end
            
            fprintf('Clustering features using GMM...\n');
            
            % call FMM mex
            gmm_params = struct;

            if ~isempty(init_mean) && ~isempty(init_var) && ~isempty(init_coef)
                vocabulary = mexGmmTrainSP(feats, obj.gmmConfiguration.voc_size, gmm_params, init_mean, init_var, init_coef);
            else
                vocabulary = mexGmmTrainSP(feats, obj.gmmConfiguration.voc_size, gmm_params);
            end
            
            fprintf('Done training codebook!\n');
            
        end
        
    end
    
end

