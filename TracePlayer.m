function [TraceMovie] = TracePlayer(ImageInfo, Background_nor, Trace)

    File_id = ImageInfo.File_id;
    TrackImageIndex = ImageInfo.TrackImageIndex;

    LeftSide = max(min(floor(Trace(:, 2)) - 100), 1);
    UpSide = max(min(floor(Trace(:, 3)) - 100), 1);

    RightSide = min(max(floor(Trace(:, 2)) + 100), ImageInfo.ImageWidth);
    DownSide = min(max(floor(Trace(:, 3)) + 100), ImageInfo.ImageHeight);

    if strcmp(ImageInfo.FileType, '.nd2')
        [FilePointer,ImagePointer,ImageReadOut] = ND2Open(File_id);
    elseif strcmp(ImageInfo.FileType, '.tif')
    else
        warning('Error!')
        return
    end

    TraceMovie = zeros(DownSide - UpSide + 1, RightSide - LeftSide + 1, size(Trace, 1));
    [X, Y] = meshgrid(LeftSide:RightSide, UpSide:DownSide);

    for i = 1:size(Trace, 1)

        if strcmp(ImageInfo.FileType, '.nd2')
            Original_Image = ND2Read(FilePointer,ImagePointer,ImageReadOut,i);
        elseif strcmp(ImageInfo.FileType, '.tif')
            Original_Image = imread(File_id, 'Index', TrackImageIndex(Trace(i, 1)), 'Info', ImageInfo.main);
        else
            warning('Error!')
            return
        end

        Normalize_Image = uint16(double(Original_Image(:, :)) ./ Background_nor);
        TraceMask = ((X - Trace(i, 2)).^2 + (Y - Trace(i, 3)).^2) < 8;
        TraceImagei = mat2gray(Normalize_Image(UpSide:DownSide, LeftSide:RightSide));
        TraceImagei(TraceMask) = 1;
        TraceMovie(:, :, i) = TraceImagei;

    end

    if strcmp(ImageInfo.FileType,'.nd2')
        calllib('Nd2ReadSdk','Lim_FileClose',FilePointer);
    else
    end

    implay(TraceMovie)

end
