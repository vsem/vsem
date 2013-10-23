function descrs = encodeImage(encoder, im, varargin)
% ENCODEIMAGE   Apply an encoder to an image
%   DESCRS = ENCODEIMAGE(ENCODER, IM) applies the ENCODER
%   to image IM, returning a corresponding code vector PSI.
%
%   IM can be an image, the path to an image, or a cell array of
%   the same, to operate on multiple images.
%
%   ENCODEIMAGE(ENCODER, IM, CACHE) utilizes the specified CACHE
%   directory to store encodings for the given images. The cache
%   is used only if the images are specified as file names.
%
%   See also: TRAINENCODER().

% Author: Andrea Vedaldi, modified by Elia Bruni

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.cacheDir = [] ;
opts.cacheChunkSize = 512 ;
opts.localization = 'global';

% TODO: Change in a more elegant solution
opts.object = [];
opts.surrounding = [];

opts = vl_argparse(opts,varargin) ;

if ~iscell(im), im = {im} ; end

% break the computation into cached chunks
startTime = tic ;
descrs = cell(1, numel(im)) ;
numChunks = ceil(numel(im) / opts.cacheChunkSize) ;

for c = 1:numChunks
    n  = min(opts.cacheChunkSize, numel(im) - (c-1)*opts.cacheChunkSize) ;
    chunkPath = fullfile(opts.cacheDir, sprintf('chunk-%03d.mat',c)) ;
    if ~isempty(opts.cacheDir) && exist(chunkPath)
        fprintf('%s: loading descriptors from %s\n', mfilename, chunkPath) ;
        load(chunkPath, 'data') ;
    else
        range = (c-1)*opts.cacheChunkSize + (1:n) ;
        fprintf('%s: processing a chunk of %d images (%3d of %3d, %5.1fs to go)\n', ...
            mfilename, numel(range), ...
            c, numChunks, toc(startTime) / (c - 1) * (numChunks - c + 1)) ;
            
        % TODO: Change in a more elegant solution
            data = processChunk(encoder, im(range), varargin{:}) ;
%         if isempty(opts.object) && isempty(opts.surrounding)
%             data = processChunk(encoder, im(range)) ;
%         elseif ~isempty(opts.object)
%             data = processChunk(encoder, im(range), opts.object) ;
%         elseif ~isempty(opts.surrounding)
%             data = processChunk(encoder, im(range), opts.surrounding) ;
%             fprintf('IM IN OBJECT')
%         end
        
        if ~isempty(opts.cacheDir)
            save(chunkPath, 'data') ;
        end
    end
    descrs{c} = data ;
    clear data ;
end
descrs = cat(2,descrs{:}) ;

% --------------------------------------------------------------------
function psi = processChunk(encoder, im, varargin)
% --------------------------------------------------------------------

psi = cell(1,numel(im)) ;
if numel(im) > 1 & matlabpool('size') > 1
    parfor i = 1:numel(im)
        psi{i} = encodeOne(encoder, im{i}, varargin{:}) ;
    end
else
    % avoiding parfor makes debugging easier
    for i = 1:numel(im)
        psi{i} = encodeOne(encoder, im{i}, varargin{:}) ;
    end
end
psi = cat(2, psi{:}) ;


% --------------------------------------------------------------------
function psi = encodeOne(encoder, im, varargin)
% --------------------------------------------------------------------

im = encoder.readImageFn(im) ;

%%% EXPERIMENTAL CODE START%%%
if nargin == 2  
    % extract feature descriptors
    %[features, frames, imageSize] = ...
    %    obj.featureExtractor.compute(imagePath);
    features = encoder.extractorFn(im);
    imageSize = size(im) ;
elseif nargin == 4
    % checking for errors in the input
    assert(any(strcmpi(varargin{1}, {'surrounding', 'object'})), 'Input must be either ''object'' or ''surrounding'' and the localization matrix.');

    % assigning localization
    xmin = varargin{2}(1); xmax = varargin{2}(2); ymin = varargin{2}(3); ymax = varargin{2}(4);
    
    switch lower(varargin{1})
        case 'surrounding'
            
            % extract feature descriptors
            features = encoder.extractorFn(im) ;
            imageSize = size(im) ;
            
            % surrounding features and image size
            features = getsurroundingFeatures(features, xmin, xmax, ymin, ymax);
            
        case 'object'
            
            % extract feature descriptors
            features = encoder.extractorFn(im) ;
            
            % object features and image size
            features = getobjectFeatures(features, xmin, xmax, ymin, ymax);
            
            imageSize = [ymax-ymin, xmax-xmin,3];
    end % switch
else
    
    % invalid input
    error('Invalid input. Provide the image path and, optionally, localization data.')
end


%%% EXPERIMENTAL CODE END%%%

psi = {} ;
for i = 1:size(encoder.subdivisions,2)
    minx = encoder.subdivisions(1,i) * imageSize(2) ;
    miny = encoder.subdivisions(2,i) * imageSize(1) ;
    maxx = encoder.subdivisions(3,i) * imageSize(2) ;
    maxy = encoder.subdivisions(4,i) * imageSize(1) ;
    
    ok = ...
        minx <= features.frame(1,:) & features.frame(1,:) < maxx  & ...
        miny <= features.frame(2,:) & features.frame(2,:) < maxy ;
    
    descrs = encoder.projection * bsxfun(@minus, ...
        features.descr(:,ok), ...
        encoder.projectionCenter) ;
    if encoder.renormalize
        descrs = bsxfun(@times, descrs, 1./max(1e-12, sqrt(sum(descrs.^2)))) ;
    end
    
    w = size(im,2) ;
    h = size(im,1) ;
    frames = features.frame(1:2,:) ;
    frames = bsxfun(@times, bsxfun(@minus, frames, [w;h]/2), 1./[w;h]) ;
    
    descrs = extendDescriptorsWithGeometry(encoder.geometricExtension, frames, descrs) ;
    
    switch encoder.type
        case 'bovw'
            [words,distances] = vl_kdtreequery(encoder.kdtree, encoder.words, ...
                descrs, ...
                'MaxComparisons', 100) ;
            z = vl_binsum(zeros(encoder.numWords,1), 1, double(words)) ;
            z = sqrt(z) ;
            
        case 'fv'
            z = vl_fisher(descrs, ...
                encoder.means, ...
                encoder.covariances, ...
                encoder.priors, ...
                'Improved') ;
        case 'vlad'
            [words,distances] = vl_kdtreequery(encoder.kdtree, encoder.words, ...
                descrs, ...
                'MaxComparisons', 15) ;
            assign = zeros(encoder.numWords, numel(words), 'single') ;
            assign(sub2ind(size(assign), double(words), 1:numel(words))) = 1 ;
            z = vl_vlad(descrs, ...
                encoder.words, ...
                assign, ...
                'SquareRoot', ...
                'NormalizeComponents') ;
    end
    z = z / max(sqrt(sum(z.^2)), 1e-12) ;
    psi{i} = z(:) ;
end
psi = cat(1, psi{:}) ;

% --------------------------------------------------------------------
function psi = getFromCache(name, cache)
% --------------------------------------------------------------------
[drop, name] = fileparts(name) ;
cachePath = fullfile(cache, [name '.mat']) ;
if exist(cachePath, 'file')
    data = load(cachePath) ;
    psi = data.psi ;
else
    psi = [] ;
end

% --------------------------------------------------------------------
function storeToCache(name, cache, psi)
% --------------------------------------------------------------------
[drop, name] = fileparts(name) ;
cachePath = fullfile(cache, [name '.mat']) ;
vl_xmkdir(cache) ;
data.psi = psi ;
save(cachePath, '-STRUCT', 'data') ;


%%% EXPERIMENTAL CODE START%%%

% --------------------------------------------------------------------
function features = getsurroundingFeatures(features, xmin, xmax, ymin, ymax)
% --------------------------------------------------------------------
% selects features from the surrounding of the annotation in an image

% computing indexes for frames outside the bounding box
idxs = bsxfun(@or,...
    bsxfun(@or,bsxfun(@le,features.frame(1,:),xmin),bsxfun(@ge,features.frame(1,:),xmax)),...
    bsxfun(@or,bsxfun(@le,features.frame(2,:),ymin),bsxfun(@ge,features.frame(2,:),ymax)));

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
%w = size(im,2) ;
%h = size(im,1) ;

frames = features.frame(1:2,:) ;
descrs = features.descr(1:2,:) ;

features.frame = descrs(:,idxs);
features.desc = frames(:,idxs);

%end % getsurroundingFeatures

% --------------------------------------------------------------------
function features = getobjectFeatures(features, xmin, xmax, ymin, ymax)
% --------------------------------------------------------------------    
 % selects features from withing the annotation in an image                

% computing indexes for frames inside the bounding box
idxs = bsxfun(@and,...
    bsxfun(@and,bsxfun(@gt,features.frame(1,:),xmin),bsxfun(@lt,features.frame(1,:),xmax)),...
    bsxfun(@and,bsxfun(@gt,features.frame(2,:),ymin),bsxfun(@lt,features.frame(2,:),ymax)));

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

frames = features.frame(1:2,:) ;
descrs = features.descr(1:2,:) ;
frames(1,:) = frames(1,:) - xmin;
frames(2,:) = frames(2,:) - ymin;

features.frame = descrs(:,idxs);
features.desc = frames(:,idxs);

% TODO: Ask Ulisse if this is necessary
% providing new coordinates, needed for spacial binning
%frames(1,:) = frames(1,:) - xmin;
%frames(2,:) = frames(2,:) - ymin;

%%% EXPERIMENTAL CODE END%%%