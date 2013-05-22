%% helpers.graphics.WaitBar class
%
% *Package:* helpers.graphics
%
% <html>
% <span style="color:#666">Handle waiting bar</span>
% </html>
%
%% Description
%
% |helpers.graphics.WaitBar| creates a handle to a Matlab
% waitbar for processedItems number of items (e.g. in a loop). text is
% displayed inside the waitbar.
%
%% Construction
%
% |waitBar = WaitBar(processedItems, text, optionalInput)|
%
%% Input Arguments
%
% The behaviour of this class can be adjusted by modifying the following options:
%
%
% |RGBColor| creates a graphical waitbar of that color by 
% putting as input a 1x3 vector with decimal RGB components.
%
% |'textVersion'| builds a textual waitbar, suited for shell or otherwise 
% non graphical.