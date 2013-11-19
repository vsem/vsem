function info = ConcatenateInfo(infoIn)
% info = ConcatenateInfo(infoIn)
%
% Concatenates the info structure.
% This basically means that the rows and columns are concatenated.

info = infoIn{1};

row = cell(1, length(infoIn));
col = cell(1, length(infoIn));
regionSize = cell(1, length(infoIn));
numDescriptors = cell(1, length(infoIn));

for i = 1:length(infoIn)
    row{i} = infoIn{i}.row;
    col{i} = infoIn{i}.col;
    regionSize{i} = infoIn{i}.regionSize;
    numDescriptors{i} = infoIn{i}.numDescriptors;
end

info.row = cat(1, row{:});
info.col = cat(1, col{:});
info.regionSize = cat(2, regionSize{:});
info.regionSize = info.regionSize(:);
info.numDescriptors = cat(1, numDescriptors{:});
