function [MeanCellSize] = CellSizeTest(ImageInfo, Background_nor, BlurSize, ExtensionRatio, varargin)

    ActiveContourStatus = 'off';
    AutoCellSize = 120;
    ActiveContourTimes = 5;

    if isempty(varargin)
    else
        for i = 1:(size(varargin, 2) / 2)
        	AssignVar(varargin{i * 2 - 1}, varargin{i * 2})
        end
    end

    File_id = ImageInfo.File_id;
    TrackChannel = ImageInfo.TrackChannel;

    if strcmp(ImageInfo.FileType, '.nd2')
        Original_Image = ND2ReadSingle(ImageInfo.File_id, TrackChannel);
    elseif strcmp(ImageInfo.FileType, '.tif')
        Original_Image = imread(File_id, 'Index', TrackChannel, 'Info', ImageInfo.main);
    end

    if strcmp(Method, 'Fluorescent')
        Normalize_Image = mat2gray(double(Original_Image(:, :)) ./ Background_nor);
    elseif strcmp(Method, 'PhaseContrast')
        Normalize_Image = 1-mat2gray(double(Original_Image(:, :)) - Background_nor);
    end
    
    [BW_Image] = BW_Single(Normalize_Image, BlurSize, ExtensionRatio, 'AutoCellSize', AutoCellSize, 'ActiveContourStatus', ActiveContourStatus, 'ActiveContourTimes', ActiveContourTimes);

    CellRegion = regionprops(BW_Image);
    CellRegion_array = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
    MeanCellSize = mean(CellRegion_array(:, 1));

    warning('off','images:initSize:adjustingMag')
    figure
    imshow(BW_Image)
    warning('on','images:initSize:adjustingMag')

end
