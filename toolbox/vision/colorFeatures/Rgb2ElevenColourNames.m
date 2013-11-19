function cNames = Rgb2ElevenColourNames(im, do3D)
% cNames = Rgb2ColourNames(im, colourNameMatrix)
%
% Converts RGB to the 11 colour names space
% Adapted from original implementation of Weijer, TIP 2011
%
% im:               rgb image in doubles
% do3D:             Logical determining if the output is a 2D array of
%                   colour names or a 3D array with probabilities for each
%                   colour name (depth = 11).
%
% cNames:           Index between 1:11 of the colour names
%
% order of color names: black   , blue    ,   brown     , grey       , green   , orange   , pink     , purple  , red     , white    , yellow
% color_values =     {  [0 0 0] , [0 0 1] , [.5 .4 .25] , [.5 .5 .5] , [0 1 0] , [1 .8 0] , [1 .5 1] , [1 0 1] , [1 0 0] , [1 1 1 ] , [ 1 1 0 ] };

if ~exist('do3D', 'var')
    do3D = false;
end

persistent colourNameMatrix;  % Declare data as a persistent variable
if isempty(colourNameMatrix)  % Check if it is empty (i.e. not initialized)
    load('elevenColourNames.mat');  %# Initialize data with the .MAT file contents
    colourNameMatrix = w2c;    
end


RR=im(:,:,1);GG=im(:,:,2);BB=im(:,:,3); % RGB channels separately

% Get indices in 32*32*32 colour cube
mulF = 255/8;
index_im = 1+floor(RR(:)*mulF)+32*floor(GG(:)*mulF)+32*32*floor(BB(:)*mulF);

if do3D
    cNames = zeros(size(im,1), size(im,2), 11);
    for i=1:11
        cNames(:,:,i) = reshape(colourNameMatrix(index_im(:),i),size(im,1),size(im,2));
    end
else
    % Colour name corresponds to maximum probability of colour name in 32*32*32
    % colour cube. These probabilities are stored in cNames.
    [max1,w2cM]=max(colourNameMatrix,[],2);  
    cNames=reshape(w2cM(index_im(:)),size(im,1),size(im,2));
end

