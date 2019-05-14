function [CellRegion_All, CellNumDetected] = BW_All(ImageInfo, Background_nor, BlurSize, ExtensionRatio, ActiveContourTimes)

    File_id = ImageInfo.File_id;
    TrackImageIndex = ImageInfo.TrackImageIndex;

    FileName = ImageInfo.FileName;
    Path = ImageInfo.Path;

    BWtifStackName = [Path, 'BW_', FileName];

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
        disp('Error!')
        return
    end

    CellNumDetected = [];
    CellRegion_All = cell(0);

    Barlength = 0;

    for i = 1:size(TrackImageIndex, 2)

        if strcmp(ImageInfo.FileType, '.nd2')
            Original_Image = bfGetPlane(r, TrackImageIndex(i));
        elseif strcmp(ImageInfo.FileType, '.tif')
            Original_Image = imread(File_id, 'Index', TrackImageIndex(i), 'Info', ImageInfo.main);
        else
            disp('Error!')
            return
        end

        Normalize_Image = uint16(double(Original_Image(:, :)) ./ Background_nor);
        BW_Image = BW_Single(Normalize_Image, BlurSize, ExtensionRatio, 'ActiveContourTimes', ActiveContourTimes);
        imwrite(BW_Image, BWtifStackNameFull, 'WriteMode', 'append', 'Compression', 'none');
        CellRegion = regionprops(BW_Image);
        CellRegion_array = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
        % remove the cells less then 5 pixels and larger than 360 pixels
        CellRegion_array(CellRegion_array(:, 1) < 5 | CellRegion_array(:, 1) > 360) = [];
        CellRegion_All{i} = CellRegion_array;
        CellNumDetected(i) = size(CellRegion_array, 1);
        [~, Barlength] = DisplayBar(i, size(TrackImageIndex, 2), Barlength);
    end

    if strcmp(ImageInfo.FileType, '.nd2')

        r.close();
        clear r
    else
    end

    if min(CellNumDetected) < 8
        LowCellNumFrame = TrackImageIndex(CellNumDetected == min(CellNumDetected));
        disp(['Warning, too few cells detected at frame ', num2str(LowCellNumFrame)])

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
        disp(['Warning, too many cells detected at frame ', num2str(ManyCellNumFrame)])

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
