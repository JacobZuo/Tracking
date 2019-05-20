function [MeanCellSize] = CellSizeTest(ImageInfo, Background_nor, BlurSize, ExtensionRatio, varargin)

    ActiveContourStatus = 'off';
    AutoCellSize = 'on';
    ActiveContourTimes = 5;

    if isempty(varargin)
    else

        for i = 1:(size(varargin, 2) / 2)

            if ischar(varargin{i * 2})
                eval([varargin{i * 2 - 1}, ' = ''', varargin{i * 2}, '''; ']);
            else
                eval([varargin{i * 2 - 1}, '=', num2str(varargin{i * 2}), ';']);
            end

        end

    end

    File_id = ImageInfo.File_id;
    TrackChannel = ImageInfo.TrackChannel;

    if strcmp(ImageInfo.FileType, '.nd2')
        r = bfGetReader(File_id, 0);
        Original_Image = bfGetPlane(r, TrackChannel);
        r.close();
        clear r
    elseif strcmp(ImageInfo.FileType, '.tif')
        Original_Image = imread(File_id, 'Index', TrackChannel, 'Info', ImageInfo.main);
    end

    Normalize_Image = uint16(double(Original_Image(:, :)) ./ Background_nor);
    [BW_Image] = BW_Single(Normalize_Image, BlurSize, ExtensionRatio, 'AutoCellSize', AutoCellSize, 'ActiveContourStatus', ActiveContourStatus, 'ActiveContourTimes', ActiveContourTimes);

    CellRegion = regionprops(BW_Image);
    CellRegion_array = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
    MeanCellSize = mean(CellRegion_array(:, 1));
    imshow(BW_Image)

end