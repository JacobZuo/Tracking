function [CellRegion_array] = SpecialCaseDetector(CellRegion)

    CellRegion_array = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
    % remove the cells less then 5 pixels and larger than 360 pixels
    CellSize = CellRegion_array(:, 1);

    CellRegion_array(CellSize < 5 | CellSize > 360) = [];

    

end
