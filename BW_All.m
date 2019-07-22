function [CellRegion_All, CellNumDetected] = BW_All(ImageInfo, Background_nor, BlurSize, ExtensionRatio, varargin)

    ActiveContourStatus = 'off';
    AutoCellSize = 'on';
    ActiveContourTimes = 5;
    Tag=char(datetime('now','format','-HH-mm-ss'));

    if isempty(varargin)
    else

        for i = 1:(size(varargin, 2) / 2)
            AssignVar(varargin{i * 2 - 1},varargin{i * 2})
        end

    end

    File_id = ImageInfo.File_id;
    TrackImageIndex = ImageInfo.TrackImageIndex;

    FileName = ImageInfo.FileName;
    Path = ImageInfo.Path;

    BWtifStackName = [Path, 'BW_', FileName, Tag];

    if exist([BWtifStackName, '.tif'], 'file') == 2
        BWtifStackNameFull = [BWtifStackName, '_', num2str(floor(rand(1) * 10^5)), '.tif'];

        while exist(BWtifStackNameFull, 'file') == 2
            BWtifStackNameFull = [BWtifStackName, '_', num2str(floor(rand(1) * 10^5)), '.tif'];
        end

    else
        BWtifStackNameFull = [BWtifStackName, '.tif'];
    end

    if strcmp(ImageInfo.FileType, '.nd2')
        r = bfGetReader(File_id, 0);
    elseif strcmp(ImageInfo.FileType, '.tif')
    else
        warning('Error!')
        return
    end

    CellNumDetected = zeros(1, size(TrackImageIndex, 2));
    CellRegion_All = cell(0);

    for i = 1:size(TrackImageIndex, 2)

        if strcmp(ImageInfo.FileType, '.nd2')
            Original_Image = bfGetPlane(r, TrackImageIndex(i));
        elseif strcmp(ImageInfo.FileType, '.tif')
            Original_Image = imread(File_id, 'Index', TrackImageIndex(i), 'Info', ImageInfo.main);
        else
            warning('Error!')
            return
        end

        Normalize_Image = uint16(double(Original_Image(:, :)) ./ Background_nor);
        BW_Image = BW_Single(Normalize_Image, BlurSize, ExtensionRatio, 'AutoCellSize', AutoCellSize, 'ActiveContourStatus', ActiveContourStatus, 'ActiveContourTimes', ActiveContourTimes);
        imwrite(BW_Image, BWtifStackNameFull, 'WriteMode', 'append', 'Compression', 'none');
        CellRegion = regionprops(BW_Image);
        CellRegion_array = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
        % remove the cells less then 5 pixels and larger than 360 pixels
        CellRegion_array(CellRegion_array(:, 1) < 5 | CellRegion_array(:, 1) > 360, :) = [];
        CellNumDetected(i) = size(CellRegion_array, 1);
        CellRegion_array(:, 8)=(sum(CellNumDetected(1:i-1))+1):sum(CellNumDetected(1:i));
        CellRegion_All{i} = CellRegion_array;
        DisplayBar(i, size(TrackImageIndex, 2));
    end

    if strcmp(ImageInfo.FileType, '.nd2')
        r.close();
        clear r
    else
    end

    if min(CellNumDetected) < 8
        LowCellNumFrame = TrackImageIndex(CellNumDetected == min(CellNumDetected));
        warning('off','backtrace')
        warning(['Too few cells detected at frame ', num2str(LowCellNumFrame)])
        warning('on','backtrace')

        %     for i = 1:size(LowCellNumFrame, 2)
        %         Original_Image = bfGetPlane(r, TrackImageIndex(LowCellNumFrame(i)));
        %         Normalize_Image = uint16(double(Original_Image(:, :)) ./ Background_nor);
        %         BW_Image = BW_Single(Normalize_Image, BlurSize, ExtensionRatio, 'ActiveContourTimes', ActiveContourTimes);
        %         imshow(BW_Image)
        %     end

    else
    end

    if max(CellNumDetected) > 300
        ManyCellNumFrame = TrackImageIndex(CellNumDetected == min(CellNumDetected));
        warning('off','backtrace')
        warning(['Too many cells detected at frame ', num2str(ManyCellNumFrame)])
        warning('on','backtrace')

        %     for i = 1:size(ManyCellNumFrame, 2)
        %         Original_Image = bfGetPlane(r, TrackImageIndex(ManyCellNumFrame(i)));
        %         Normalize_Image = uint16(double(Original_Image(:, :)) ./ Background_nor);
        %         BW_Image = BW_Single(Normalize_Image, BlurSize, ExtensionRatio, 'ActiveContourTimes', ActiveContourTimes);
        %         imshow(BW_Image)
        %     end

    else
    end

    disp(['The mean cells num is about: ', num2str(floor(mean(CellNumDetected)))])
    disp(['The B/W movie is saved as ', ImageInfo.FileName, '.tif'])

end
