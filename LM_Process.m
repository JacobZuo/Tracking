function [CellRegion_All, CellNumDetected] = LM_Process(ImageInfo, varargin)

    if isempty(varargin)
        Range = 6;
        Tolerance = 'auto';
    elseif size(varargin, 2) == 1
        Range = 6;
        Tolerance = varargin{1};
    elseif size(varargin, 2) == 2
        Range = varargin{1};
        Tolerance = varargin{2};
    else
        warning('Error!')
        return
    end

    File_id = ImageInfo.File_id;
    TrackImageIndex = ImageInfo.TrackImageIndex;

    FileName = ImageInfo.FileName;
    Path = ImageInfo.Path;
    Tag = char(datetime('now', 'format', '-HH-mm-ss'));

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
        [FilePointer, ImagePointer, ImageReadOut] = ND2Open(File_id);
    elseif strcmp(ImageInfo.FileType, '.tif')
    else
        warning('Error!')
        return
    end

    CellNumDetected = zeros(1, ImageInfo.numImages);
    CellRegion_All = cell(0);

    for i = 1:size(TrackImageIndex, 2)

        if strcmp(ImageInfo.FileType, '.nd2')
            Original_Image = ND2Read(FilePointer, ImagePointer, ImageReadOut, TrackImageIndex(i));
        elseif strcmp(ImageInfo.FileType, '.tif')
            Original_Image = imread(File_id, 'Index', TrackImageIndex(i), 'Info', ImageInfo.main);
        else
            warning('Error!')
            return
        end

        [BW_Image, CellRegion_array] = LocalMax(Original_Image, Range, Tolerance);

        CellNumDetected(i) = size(CellRegion_array, 1);
        CellRegion_array(:, 8) = (sum(CellNumDetected(1:i - 1)) + 1):sum(CellNumDetected(1:i));

        CellRegion_All{i} = CellRegion_array;
        imwrite(BW_Image, BWtifStackNameFull, 'WriteMode', 'append', 'Compression', 'none');

        if i == 1
            figure
            imshow(Original_Image)
            hold on
            plot(CellRegion_array(:, 2), CellRegion_array(:, 3), 'o', 'MarkerSize', 12, 'LineWidth', 2)
            hold off
            axis off
            pause(0.1);
        else
        end

        DisplayBar(i, size(TrackImageIndex, 2));

    end

    if strcmp(ImageInfo.FileType, '.nd2')
        ND2Close(FilePointer);
        clear('FilePointer');
    else
    end

    if min(CellNumDetected) < 8
        LowCellNumFrame = TrackImageIndex(CellNumDetected == min(CellNumDetected));
        warning('off', 'backtrace')
        warning(['Too few cells detected at frame ', num2str(LowCellNumFrame)])
        warning('on', 'backtrace')

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
        warning('off', 'backtrace')
        warning(['Too many cells detected at frame ', num2str(ManyCellNumFrame)])
        warning('on', 'backtrace')

        %     for i = 1:size(ManyCellNumFrame, 2)
        %         Original_Image = bfGetPlane(r, TrackImageIndex(ManyCellNumFrame(i)));
        %         Normalize_Image = uint16(double(Original_Image(:, :)) ./ Background_nor);
        %         BW_Image = BW_Single(Normalize_Image, BlurSize, ExtensionRatio, 'ActiveContourTimes', ActiveContourTimes);
        %         imshow(BW_Image)
        %     end

    else
    end

    disp(['The mean cells num is about: ', num2str(floor(mean(CellNumDetected)))])
    disp(['The B/W movie is saved as: ', BWtifStackName])

end
