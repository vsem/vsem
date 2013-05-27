classdef PhowFeatureExtractor < handle & vision.features.GenericFeatureExtractor
    % PhowFeatureExtractor Feature extractor for PHOW features
    %
    %   For help, see help vl_phow

    properties
        % properties documented on vl_phow page in vl_feat docs
        phowConfiguration = struct(...
            'verbose', false,...
            'sizes', [4 6 8 10],...
            'fast', true,...
            'step', 2,...
            'color', 'gray',...
            'contrast_threshold', 0.005,...
            'window_size', 1.5,...
            'magnif', 6,...
            'float_descriptors', false,...
            'remove_zero', false,... % remove zero vectors
            'low_proj', [],... % dimensionality reducing projection
            'rootSift', false); % root Sift, false by default
    end

    methods
        function obj = PhowFeatureExtractor(varargin)
            obj.phowConfiguration = vl_argparse(obj.phowConfiguration, varargin);

            % the output dimension is set to 128 in the superclass
            obj.phowConfiguration.out_dim = obj.out_dim;
        end

        function [feats, frames] = compute(obj, imagePath)
            % read and standardize image 
            image = obj.readImage(imagePath);
            image = obj.standardizeImage(image);

            [frames, feats] = vl_phow(image, 'Verbose', obj.phowConfiguration.verbose, ...
                'Sizes', obj.phowConfiguration.sizes, 'Fast', obj.phowConfiguration.fast, 'step', obj.phowConfiguration.step, ...
                'Color', obj.phowConfiguration.color, 'ContrastThreshold', obj.phowConfiguration.contrast_threshold, ...
                'WindowSize', obj.phowConfiguration.window_size, 'Magnif', obj.phowConfiguration.magnif, ...
                'FloatDescriptors', obj.phowConfiguration.float_descriptors);
            feats = single(feats);

            if obj.phowConfiguration.rootSift
                % calculate root sift
                feats = sqrt(feats/sum(feats));
            end

            if obj.phowConfiguration.remove_zero
                % remove zero features
                nz_feat = any(feats, 1);

                feats = feats(:, nz_feat);
                frames = frames(:, nz_feat);
            end

            if ~isempty(obj.phowConfiguration.low_proj)
                % dimensionality reduction
                feats = obj.phowConfiguration.low_proj * feats;        
            end
        end
    end
end

