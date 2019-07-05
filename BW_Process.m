function [CellRegion_All, CellNumDetected] = BW_Process(BW_Image,ImageInfo)

    for i = 1:ImageInfo.numImages
        
        if ischar(BW_Image)
            BW_Image_frame = imread(BW_Image, 'Index', i, 'Info', ImageInfo.main);
        	CellRegion = regionprops(BW_Image_frame);
        else
            CellRegion = regionprops(BW_Image(:,:,i));
        end
        CellRegion_array = (reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';
        CellRegion_array(CellRegion_array(:, 1) < 5 | CellRegion_array(:, 1) > 360, :) = [];
        CellRegion_All{i} = CellRegion_array;
        CellNumDetected(i) = size(CellRegion_array, 1);
        DisplayBar(i, ImageInfo.numImages);
    end

    disp(['The mean cells num is about: ', num2str(floor(mean(CellNumDetected)))])

end

