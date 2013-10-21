 function histogram = extractImageHistogram(obj, imagePath, varargin)
            if nargin == 2
                % extract feature descriptors
                [features, frames, imageSize] = ...
                    obj.featureExtractor.compute(imagePath);
            elseif nargin == 4

                % checking for errors in the input
                assert(any(strcmpi(varargin{1}, {'surrounding', 'object'})), 'Input must be either ''object'' or ''surrounding'' and the localization matrix.');

                % assigning localization
                xmin = varargin{2}(1); xmax = varargin{2}(2); ymin = varargin{2}(3); ymax = varargin{2}(4);

                switch lower(varargin{1})
                    case 'surrounding'

                        % extract feature descriptors
                        [features, frames, imageSize] = ...
                            obj.featureExtractor.compute(imagePath);

                        % surrounding features and image size
                        [features, frames] = getsurroundingFeatures(features, frames, xmin, xmax, ymin, ymax);

                    case 'object'

                        % extract feature descriptors
                        [features, frames, imageSize] = ...
                            obj.featureExtractor.compute(imagePath);

                        % object features and image size
                        [features, frames] = getobjectFeatures(features, frames, xmin, xmax, ymin, ymax);

                        imageSize = [ymax-ymin, xmax-xmin,3];
                end % switch
            else

                % invalid input
                error('Invalid input. Provide the image path and, optionally, localization data.')
            end

            % compute histogram
            histogram = obj.pooler.compute(imageSize, features, frames);


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

            end % getsurroundingFeatures

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
            end % getobjectFeatures
        end % extractImageHistogram