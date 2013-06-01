classdef PCADimensionalityReduction < handle & vision.features.helpers.dimensionality.GenericDimensionalityReduction
% PCADimensionalityReduction Learns descriptor dimensionality reduction using PCA
%
%   Options are:
%
%   'descount_limit':: 1e6
%     Maximum number of features to be use for dimensionality reduction.
%     Set to > 1 applies no discount.

    properties
        pcaConfiguration = struct(...
            'descount_limit', 1e6);
        dim % target dimensionality
    end
    
    methods
        function obj = PCADimensionalityReduction(featureExtractor, dim, varargin)
            obj.featureExtractor = featureExtractor;
            obj.dim = dim; % dimensionality, which has no predefinite value
                           % because there should be no dimensionality
                           % reduction without setting it
            
            obj.pcaConfiguration = vl_argparse(obj.pcaConfiguration, varargin);
        end
        
        function low_proj = train(obj, imagesPaths, varargin)
            %Train
            %
            % -------------------------------------------------------------------------
            % 1. Extract features for training into 'feats' matrix
            %     applying any limits on number of features/images
            % -------------------------------------------------------------------------
            
            if obj.pcaConfiguration.descount_limit > 0
                % set truncation value for image features just a little bit
                % larger than descount_limit, so if there are any images
                % with fewer than descount_limit/numImages we still have
                % some chance of getting descount_limit descriptors in the end
                img_descount_limit = ceil(obj.pcaConfiguration.descount_limit / ...
                    length(imagesPaths) * 1.1);
                % fprintf('Extracting a maximum of %d features from each image...\n', ...
                %     img_descount_limit);
            else
                img_descount_limit = [];
            end
            
            feats = cell(length(imagesPaths),1);
            
            % setting for progress bar graphics and variables
            pfImcount = length(imagesPaths);
            text = 'Computing features for PCA: ';
            barColor = [0.53 0.90 0.93];
            waitBar = helpers.graphics.WaitBar(pfImcount, text, barColor);
            
            % iterate through images, computing features
            % parfor ii = 1:pfImcount
            for ii = 1:pfImcount
                % fprintf('Computing features for: %s %f %% complete\n', ...
                %     imagesPaths{ii}, ii/pfImcount*100.00);
                
                % updates waitbar
                % waitBar.update(pfImcount-ii+1); % parfor version
                waitBar.update(ii);

                try
                    feats_all = obj.featureExtractor.compute(imagesPaths{ii});
                    
                    % if a descount limit applies, discard a fraction of features now to
                    % save memory
                    if obj.pcaConfiguration.descount_limit > 0
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
                            fprintf(1, 'Error reading file: %s\n', ...
                                imagesPaths{ii});
                    end
                end % try-catch block

                if ~waitBar.textualVersion && getappdata(waitBar.bar,'canceling')
                    error('Interrupted by the user.\n');
                end
            end

            clear waitBar feats_all;
            % concatenate features into a single matrix
            feats = cat(2, feats{:});
            
            extractedFeatCount = size(feats,2);
            % fprintf('%d features extracted\n', extractedFeatCount);
            
            if obj.pcaConfiguration.descount_limit > 0
                % select subset of features for training
                feats = vl_colsubset(feats, obj.pcaConfiguration.descount_limit);
                % output status message
                % fprintf('%d features will be used for PCA (%f %%)\n', ...
                %     obj.pcaConfiguration.descount_limit, obj.pcaConfiguration.descount_limit/extractedFeatCount*100.0);
            end
            
            % -------------------------------------------------------------------------
            % 2. Perform PCA on the samples
            % -------------------------------------------------------------------------
            
            fprintf('Performing PCA...\n');
            
            low_proj = princomp(feats');
            low_proj = low_proj(:, 1:obj.dim)';
            
            fprintf('Done learning dimensionality reduction!\n');
            
        end
        
        
    end
    
end

