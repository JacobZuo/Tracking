function [Trace_All] = TrackingBW(BW_Image_File, varargin)

    if isempty(varargin)
        [ImageInfo, BW_Image] = BWInfo(BW_Image_File);
    else
        ImageInfo=varargin{1};
    end

    
    disp('--------------------------------------------------------------------------------')
    disp('B/W Image Processing...')
        [CellRegion_All, ~] = BW_Process(BW_Image, ImageInfo);

    % PartOne find the locations of cells
    disp('--------------------------------------------------------------------------------')
    disp('Finding cells locations ...')
    [Cell_Centroid, Cell_Size, V, C] = PositionLocator(CellRegion_All, ImageInfo);

    disp('Finished!')

    % PartTwo link the cells between neighbour frames
    disp('--------------------------------------------------------------------------------')
    disp('Tracking cells between neighbour frames')
    [trace_result] = TrackCellBetweenFrames(Cell_Centroid, Cell_Size, V, C);

    disp('Finished!')

    % PartThree connect all the traces
    disp('--------------------------------------------------------------------------------')
    disp('Connect cells traces')
    [Trace_All] = TraceConnector(trace_result);

    disp('Finished!')
    disp('--------------------------------------------------------------------------------')
    disp('Saving data!')
    clear('i')

    disp('--------------------------------------------------------------------------------')
    save([ImageInfo.Path, 'Trace ', ImageInfo.FileName, '.mat'],'CellRegion_All','trace_result','Trace_All')

end

