classdef VsemHistogramExtractor
% VsemHistogramExtractor histogram extractor for VQ and Fisher encoding and
%   for SPMPooler.
%   VsemHistogramExtractor(featureExtractor, vocabulary, 'optionName',
%   'optionValue') allows the extraction of bovw histograms thanks to the
%   'featureExtractor' visual features extraction utility and 'vocabulary'
%   visual vocabulary.
%
%   A multitude of options is available:
%
%   'encoding':: 'vq'
%     Encoding type, either 'vq' or 'fisher'.
%
%   'localization':: 'global'
%     Localization level, 'global', 'object' or 'surrounding'.
%
%   'vq_norm_type':: 'none'
%     Normalization to be applied to vq encoding, either 'l1', 'l2' or
%     'none'.
%
%   'max_comps':: 25
%     Maximum number of comparisons used when finding NN using kdtrees.
%
%   'grad_weights':: false
%     "soft" BOW.
%
%   'grad_means':: true
%     1st order.
%
%   'grad_variances':: true
%     2nd order.
%   
%   'alpha':: single(1.0)
%     Power normalization, set to 1 to disable.
%
%   'pnorm':: single(0.0)
%     Norm regularisation, set to 0 to disable.
%
%   'subbin_norm_type':: 'none'
%     Normalization to be applied to SPM subbins, 'l1', 'l2' or 'none'.
%
%   'norm_type':: 'none'
%     Normalization to be applied to whole SPM vector, 'l1', 'l2' or
%     'none'.
%
%   'post_norm_type':: 'none'
%     Normalization post kernel map, either 'l1' or 'l2', any other value
%     equals to 'none'.
%
%   'pool_type':: 'sum'
%     SPM pooling type, either 'sum' or 'max'.
%
%   'quad_divs':: 2
%     Number of square divisions.
%
%   'horiz_divs':: 3
%     Number of horizontal divisions.
%
%   'kermap':: 'none'
%     Additive kernel map to be applied to SPM, either 'none', 'homker' or
%     'hellinger'.
%
%
% Authors: A2
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

    
    properties
        featureExtractor
        vocabulary
        encoder
        pooler
        
        options = struct(...
            'encoding', 'vq',...
            'localization', 'global');
    end
    
    properties (Hidden)
        vqEncoderConfiguration = struct(...
            'vq_norm_type', 'none', ...
            'max_comps', 25);
        
        fisherEncoderConfiguration = struct(...
            'grad_weights', false,...
            'grad_means', true,...
            'grad_variances', true,...
            'alpha', single(1.0),...
            'pnorm', single(0.0));
        
        poolingConfiguration = struct(...
            'subbin_norm_type', 'none',...
            'norm_type', 'none',...
            'post_norm_type', 'none',...
            'pool_type', 'sum',...
            'quad_divs', 2,....
            'horiz_divs', 3,...
            'kermap', 'none');
    end
    
    properties (Constant, Hidden)
        encodings = {'vq', 'fisher'};
        localization = {'global', 'object', 'surrounding'};
        kermap = {'none', 'homker', 'hellinger'};
    end
    
    methods
        function obj = VsemHistogramExtractor(featureExtractor, vocabulary, varargin)
            
            % assigning features extractor and vocabulary
            % to the respective properties
            obj.featureExtractor = featureExtractor;
            obj.vocabulary = vocabulary;
            
            % parsing and checking general options
            [obj.options, varargin] = vl_argparse(obj.options, varargin);
            assert(ismember(lower(obj.options.encoding), obj.encodings), 'Select either ''vq'' or ''fisher'' encoding method.');
            assert(ismember(lower(obj.options.localization), obj.localization), 'Select either ''global'', ''object'' or ''surrounding'' localization.');
            
            % parsing encoding configuration
            switch lower(obj.options.encoding)
                case 'vq'
                    [obj.options.encoderConfiguration, varargin] = vl_argparse(obj.vqEncoderConfiguration, varargin);
                    encoderInput = struct2cell(obj.options.encoderConfiguration);
                    obj.encoder = vision.histograms.bovwhistograms.encoding.VQEncoder(encoderInput{:}, obj.vocabulary);
                case 'fisher'
                    [obj.options.encoderConfiguration, varargin] = vl_argparse(obj.fisherEncoderConfiguration, varargin);
                    encoderInput = struct2cell(obj.options.encoderConfiguration);
                    obj.encoder = vision.histograms.bovwhistograms.encoding.FKEncoder(encoderInput{:}, obj.vocabulary);
            end
            
            % parsing and checking pooling configuration
            obj.options.poolingConfiguration = vl_argparse(obj.poolingConfiguration, varargin);
            assert(ismember(lower(obj.options.poolingConfiguration.kermap), obj.kermap), 'Select either ''none'', ''homker'' or ''hellinger'' kermap.');
            
            poolerInput = struct2cell(obj.options.poolingConfiguration);
            obj.pooler = vision.histograms.bovwhistograms.pooling.SPMPooler(poolerInput{:}, obj.encoder);
        end
        
        function [histogram, objectList] = extractHistogram(obj, image)
        % extractHistogram histogram extraction method
        %   extractHistogram(obj, image) extracts a histogram for the image
        %   'image', according to the options set in the
        %   VsemHistogramExtractor object.
               
        
            try
                % extracting annotation when present
                annotation = image{2};
                
                % extracting image data
                image = imread(image{1});
                
                % for images with annotation
                singleImage = false;
            catch
                % extracting image data
                image = imread(image);
                
                % for single histograms (no annotation)
                singleImage = true;
            end
            
            % standardizing image data
            image = obj.featureExtractor.standardizeImage(image);
            
            % computing features
            [features, frames] = obj.featureExtractor.compute(image);
            
            % shorter output for single images
            if singleImage
                histogram = obj.pooler.compute(size(image),features, frames);
                return
            end
            
            switch lower(obj.options.localization)
                case 'global'
                    
                    % extracting unique objects for the image
                    objectList = cellfun(@(x)x, annotation(1,:), 'UniformOutput', false);
                    objectList = unique(objectList);
                    
                    % computing histogram
                    histogram = obj.pooler.compute(size(image),features, frames);
                    
                case 'surrounding'
                    
                    % checking for input errors
                    assert(size(annotation, 1) == 2,'Localization data unavailable, check annotation or select ''global'' localization.')
                    
                    % extracting object list
                    objectList = cellfun(@(x)x, annotation(1,:), 'UniformOutput', false)';
                    
                    % initializing histogram representation
                    histogram = cell(1, size(annotation, 2));
                    
                    % iterating over the whole set of concepts
                    for k = 1:size(annotation, 2)
                        
                        % extracting bounding box
                        boundingBox = annotation{2,k};
                        xmin = boundingBox(1); xmax = boundingBox(2); ymin = boundingBox(3); ymax = boundingBox(4);
                        
                        % selecting features
                        [surroundingFts,surroundingFrms] = getsurroundingFeatures(features, frames, xmin, xmax, ymin, ymax);
                        
                        % computing histogram for the kth object
                        histogram{k} = obj.pooler.compute(size(image),surroundingFts, surroundingFrms);
                    end
                    
                    % standardizing histogram
                    histogram = cat(2, histogram{:});
                    
                case 'object'
                    
                    % checking for input errors
                    assert(size(annotation, 1) == 2,'Localization data unavailable, check annotation or select ''global'' localization.')
                    
                    % extracting object list
                    objectList = cellfun(@(x)x, annotation(1,:), 'UniformOutput', false)';

                    % initializing histogram representation
                    histogram = cell(1, size(annotation, 2));
                    
                    % iterating over the whole set of concepts
                    for k = 1:size(annotation, 2)
                        
                        % extracting bounding box
                        boundingBox = annotation{2,k};
                        xmin = boundingBox(1); xmax = boundingBox(2); ymin = boundingBox(3); ymax = boundingBox(4);
                        
                        % selecting features
                        [objectFts,objectFrmes] = getobjectFeatures(features, frames, xmin, xmax, ymin, ymax);
                        
                        % computing histogram for the kth object
                        histogram{k} = obj.pooler.compute([ymax-ymin, xmax-xmin,3],objectFts, objectFrmes);
                    end
                    
                    % standardizing histogram
                    histogram = cat(2, histogram{:});
            end
            
            % selects features from the surrounding of the annotation in an image
            function [feats,frames] = getsurroundingFeatures(feats, frames, xmin, xmax, ymin, ymax)
                
                % computing indexes for frames outside the bounding box
                idxs = bsxfun(@or,...
                    bsxfun(@or,bsxfun(@le,frames(1,:),xmin),bsxfun(@ge,frames(1,:),xmax)),...
                    bsxfun(@or,bsxfun(@le,frames(2,:),ymin),bsxfun(@ge,frames(2,:),ymax)));
                
                % Extended (computationally expensive) version
                % idxs = zeros(1, size(frames, 2));
                % for i=1:length(frames)
                %     X = frames(1,i);
                %     Y = frames(2,i);
                %     if (((X < xmin) || (X > xmax)) || ((Y < ymin) || (Y > ymax)))
                %         idxs(i)=1;
                %     end
                % end
                % idxs = logical(idxs);
                
                % updating features and frames
                feats = feats(:,idxs);
                frames = frames(:,idxs);
                
            end
            
            % selects features from withing the annotation in an image
            function [feats,frames] = getobjectFeatures(feats, frames, xmin, xmax, ymin, ymax)
                
                % computing indexes for frames inside the bounding box
                idxs = bsxfun(@and,...
                    bsxfun(@and,bsxfun(@gt,frames(1,:),xmin),bsxfun(@lt,frames(1,:),xmax)),...
                    bsxfun(@and,bsxfun(@gt,frames(2,:),ymin),bsxfun(@lt,frames(2,:),ymax)));
                
                % Extended (computationally expensive) version
                % idxs = zeros(1, size(frames, 2));
                % for i=1:length(frames)
                %     X = frames(1,i);
                %     Y = frames(2,i);
                %     if (((X > xmin) && (X < xmax)) && ((Y > ymin) && (Y < ymax)))
                %        idxs(i)=1;
                %     end
                % end
                % idxs = logical(idxs);
                
                % updating features and frames
                feats = feats(:,idxs);
                frames = frames(:,idxs);
                
                % providing new coordinates, needed for spacial binning
                frames(1,:) = frames(1,:) - xmin;
                frames(2,:) = frames(2,:) - ymin;
            end
        end
    end
end
