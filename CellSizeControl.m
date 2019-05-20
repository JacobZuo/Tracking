function [BW_Image_Result, MeanCellSize] = CellSizeControl(BW_Image, varargin)

    if isempty(varargin)
        CellSize_default = 120;
    else
        CellSize_default = cell2mat(varargin);
    end

    BW_Image_Result = zeros(size(BW_Image));

    BW_Image_Small = bwpropfilt(BW_Image, 'Area', [CellSize_default * 0.05, CellSize_default * 0.4]);
    se_increase = strel('disk', 6);
    BW_Image_Small = imdilate(BW_Image_Small, se_increase);
    se_decrease = strel('disk', 3);
    BW_Image_Small = imerode(BW_Image_Small, se_decrease);

    BW_Image_Result = BW_Image_Result + BW_Image_Small;

    BW_Image_Middle = bwpropfilt(BW_Image, 'Area', [CellSize_default * 0.4, CellSize_default * 0.8]);
    se_increase = strel('disk', 1);
    BW_Image_Middle = imdilate(BW_Image_Middle, se_increase);

    BW_Image_Result = BW_Image_Result + BW_Image_Middle;

    BW_Image_Result = BW_Image_Result + bwpropfilt(BW_Image, 'Area', [CellSize_default * 0.8, CellSize_default * 1.4]);

    
    BW_Image_Rest = BW_Image;
    se_decrease = strel('disk', 1);
    CellRegion = regionprops(BW_Image_Rest);
    CellRegion_mat = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
    

    while max(CellRegion_mat(:, 1)) > CellSize_default * 1.4
        BW_Image_Rest = bwpropfilt(BW_Image_Rest, 'Area', [CellSize_default * 1.4, max(CellRegion_mat(:, 1))]);
        BW_Image_Rest = imerode(BW_Image_Rest, se_decrease);
        CellRegion = regionprops(BW_Image_Rest);
        CellRegion_mat = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
        BW_Image_Result = BW_Image_Result + bwpropfilt(BW_Image_Rest, 'Area', [0, CellSize_default * 1.4]);
    end
    
    BW_Image_Result = BW_Image_Result > 0.5;

    se_decrease = strel('disk', 1);
    BW_Image_Result = imerode(BW_Image_Result, se_decrease);
    se_increase = strel('disk', 1);
    BW_Image_Result = imdilate(BW_Image_Result, se_increase);

    CellRegion = regionprops(BW_Image_Result);
    CellRegion_mat = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
    MeanCellSize = mean(CellRegion_mat(:, 1));
end
