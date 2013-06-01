classdef KmeansVocabulary < vision.vocabulary.GenericVocabulary
% KmeansVocabulary Generate visual words vocabulary using kmeans
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

    properties
        kmeansConfiguration = struct(...
            'descount_limit', 1e6,... 
            'trainimage_limit', -1,...
            'voc_size', 1000)
    end
    
    methods
        function obj = KmeansVocabulary(varargin)
            obj.kmeansConfiguration = vl_argparse(obj.kmeansConfiguration, varargin);
            
            % maximum number of comparisons when using ANN (-1 = exact)
            obj.kmeansConfiguration.maxcomps = ceil(obj.kmeansConfiguration.voc_size/4);
        end
    end
    
    methods
        function vocabulary = trainVocabulary(obj, imagesPaths, featureExtractor)

            % -------------------------------------------------------------------------
            % 1. Extract features for training into 'feats' matrix
            %     applying any limits on number of features/images
            % -------------------------------------------------------------------------
            
            if obj.kmeansConfiguration.trainimage_limit > 0
                idxs = 1:length(imagesPaths);
                idxs = vl_colsubset(idxs, obj.kmeansConfiguration.trainimage_limit);
                imagesPaths = imagesPaths(idxs);
            end
            
            if obj.kmeansConfiguration.descount_limit > 0
                % set truncation value for image features just a little bit
                % larger than descount_limit, so if there are any images
                % with fewer than descount_limit/numImages we still have
                % some chance of getting descount_limit descriptors in the end
                img_descount_limit = ceil(obj.kmeansConfiguration.descount_limit / ...
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
            barColor = [0.04 0.38 0];
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
               
                try
                    feats_all = featureExtractor.compute(imagesPaths{ii});
                
                    % if a descount limit applies, discard a fraction of features now to
                    % save memory
                    if obj.kmeansConfiguration.descount_limit > 0
                        feats{ii} = vl_colsubset(feats_all, ...
                            img_descount_limit);
                    else
                        feats{ii} = feats_all;
                    end
                catch ME
                    switch ME.identifier
                        case 'VSEM:FeatExt'
                            fprintf(1, '%s\n', ME.message);
                        otherwise
                            fprintf(1, 'Error reading file: %s\n', imagesPaths{ii});
                    end
                end % try-catch block
            end % image iteration
            
            clear waitBar feats_all;
            % concatenate features into a single matrix
            feats = cat(2, feats{:});
            
            % extractedFeatCount = size(feats,2);
            % fprintf('%d features extracted\n', extractedFeatCount);
            
            if obj.kmeansConfiguration.descount_limit > 0
                % select subset of features for training
                feats = vl_colsubset(feats, obj.kmeansConfiguration.descount_limit);
                % output status message
                % fprintf('%d features will be used for training the visual vocabulary: (%f %%)\n', ...
                %     obj.kmeansConfiguration.descount_limit, obj.kmeansConfiguration.descount_limit/extractedFeatCount*100.0);
            end
            
            % -------------------------------------------------------------------------
            % 2. Cluster codebook centres
            % -------------------------------------------------------------------------
            
            fprintf('Clustering features...\n');
            
            % if maxcomps is below 1, then use exact kmeans, else use approximate
            % kmeans with maxcomps number of comparisons for distances
            if obj.kmeansConfiguration.maxcomps < 1
                vocabulary = vl_kmeans(feats, obj.kmeansConfiguration.voc_size, ...
                    'verbose', 'algorithm', 'elkan');
            else
                vocabulary = vision.vocabulary.helpers.annkmeans(feats, obj.kmeansConfiguration.voc_size, ...
                    'verbose', true, 'MaxNumComparisons', obj.kmeansConfiguration.maxcomps, ...
                    'MaxNumIterations', 150);
            end
            
            fprintf('Done training codebook!\n');
            
        end
    end
end
