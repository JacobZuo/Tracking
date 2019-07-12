function [BlurSize, ExtensionRatio] = ThresholdTest(ImageInfo, Background_nor)

    File_id = ImageInfo.File_id;
    TrackChannel = ImageInfo.TrackChannel;

    if strcmp(ImageInfo.FileType, '.nd2')
        Original_Image = ND2ReadSingle(ImageInfo.File_id, TrackChannel);
    elseif strcmp(ImageInfo.FileType, '.tif')
        Original_Image = imread(File_id, 'Index', TrackChannel, 'Info', ImageInfo.main);
    end

    Normalize_Image = uint16(double(Original_Image(:, :)) ./ Background_nor);

    BlurSize_test = 0.5:0.5:3;
    ExtensionRatio_test = 1:1:8;

    CellRegion_All = cell(0);
    CellNumDetected = [];
    NoiseNum = [];

    Test_Index = 0;

    disp('--------------------------------------------------------------------------------')
    disp('Coarse tuning...')

    for BlurSize_index = 1:size(BlurSize_test, 2)

        for ExtensionRatio_index = 1:size(ExtensionRatio_test, 2)
            [BW_Image] = BW_Single(Normalize_Image, BlurSize_test(BlurSize_index), ExtensionRatio_test(ExtensionRatio_index), 'AutoCellSize', 'off', 'ActiveContourStatus', 'off');
            CellRegion = regionprops(BW_Image);
            CellRegion_All{BlurSize_index}{ExtensionRatio_index} = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
            CellNumDetected(BlurSize_index, ExtensionRatio_index) = size(CellRegion, 1);
            CellSize = CellRegion_All{BlurSize_index}{ExtensionRatio_index}(:, 1);
            NoiseNum(BlurSize_index, ExtensionRatio_index) = sum(CellSize < 5);
            Test_Index = Test_Index + 1;
            DisplayBar(Test_Index, size(BlurSize_test, 2) * size(ExtensionRatio_test, 2));
        end

    end
    
    if exist('Warning', 'var')
        warning('off','backtrace')
        warning('Fitting background hist with RSquare < 0.98.')
        warning('on','backtrace')
        clear('Warning')
    else
    end
    
    [BlurSize_better_Index, ExtensionRatio_better_Index] = find(CellNumDetected == max(CellNumDetected(NoiseNum < 3)));

    BlurSize_test_fine = (mean(BlurSize_test(BlurSize_better_Index)) - 0.2):0.1:(mean(BlurSize_test(BlurSize_better_Index)) + 0.2);
    ExtensionRatio_test_fine = (mean(ExtensionRatio_test(ExtensionRatio_better_Index)) - 0.4):0.2:(mean(ExtensionRatio_test(ExtensionRatio_better_Index)) + 0.4);

    CellRegion_All = cell(0);
    CellNumDetected = [];
    NoiseNum = [];

    Test_Index = 0;

    disp('--------------------------------------------------------------------------------')
    disp('Fine tuning...')

    for BlurSize_index = 1:size(BlurSize_test_fine, 2)

        for ExtensionRatio_index = 1:size(ExtensionRatio_test_fine, 2)
            [BW_Image] = BW_Single(Normalize_Image, BlurSize_test_fine(BlurSize_index), ExtensionRatio_test_fine(ExtensionRatio_index), 'AutoCellSize', 'off', 'ActiveContourStatus', 'off');
            CellRegion = regionprops(BW_Image);
            CellRegion_All{BlurSize_index}{ExtensionRatio_index} = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
            CellNumDetected(BlurSize_index, ExtensionRatio_index) = size(CellRegion, 1);
            CellSize = CellRegion_All{BlurSize_index}{ExtensionRatio_index}(:, 1);
            NoiseNum(BlurSize_index, ExtensionRatio_index) = sum(CellSize < 5);
            Test_Index = Test_Index + 1;
            DisplayBar(Test_Index, size(BlurSize_test_fine, 2) * size(ExtensionRatio_test_fine, 2));
        end

    end
    
    if exist('Warning', 'var')
        warning('off','backtrace')
        warning('Fitting background hist with RSquare < 0.98.')
        warning('on','backtrace')
        clear('Warning')
    else
    end

    [BlurSize_best_Index, ExtensionRatio_best_Index] = find(CellNumDetected == max(CellNumDetected(NoiseNum < 3)));

    BlurSize = mean(BlurSize_test_fine(BlurSize_best_Index));
    ExtensionRatio = mean(ExtensionRatio_test_fine(ExtensionRatio_best_Index));

end
