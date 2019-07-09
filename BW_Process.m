function [CellRegion_All, CellNumDetected] = BW_Process(BW_Image,ImageInfo)


    CellNumDetected = zeros(1, ImageInfo.numImages);
    CellRegion_All = cell(0);
    
    for i = 1:ImageInfo.numImages
        
        if ischar(BW_Image)
            BW_Image_frame = imread(BW_Image, 'Index', i, 'Info', ImageInfo.main);
        	CellRegion = regionprops(BW_Image_frame);
        else
            CellRegion = regionprops(BW_Image(:,:,i));
        end
        CellRegion_array = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
        CellRegion_array(CellRegion_array(:, 1) < 5 | CellRegion_array(:, 1) > 360, :) = [];
        CellNumDetected(i) = size(CellRegion_array, 1);
        CellRegion_array(:, 8)=(sum(CellNumDetected(1:i-1))+1):sum(CellNumDetected(1:i));
        CellRegion_All{i} = CellRegion_array;
        DisplayBar(i, ImageInfo.numImages);
    end

    disp(['The mean cells num is about: ', num2str(floor(mean(CellNumDetected)))])

end

