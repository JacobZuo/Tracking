function [ImageInfo] = ImageFileInfo(FileName,ChannelNum,varargin)

    if isempty(varargin)
    else
        TrackChannel=varargin;
    end


    [Path, Name, Type] = fileparts(FileName);
    ImageInfo.File_id = FileName;
    ImageInfo.Path = [Path, '\'];
    ImageInfo.FileName = Name;
    ImageInfo.FileType = Type;

    if strcmp(ImageInfo.FileType, '.nd2')

        r = bfGetReader(ImageInfo.File_id, 0);
        ImageInfo.main = r.getGlobalMetadata();
        ImageInfo.numImages = r.getImageCount();
        ImageInfo.ImageWidth = r.getSizeX();
        ImageInfo.ImageHeight = r.getSizeY();
        r.close();
        clear r

    elseif strcmp(ImageInfo.FileType, '.tif')

        ImageInfo.main = imfImageInfo(ImageInfo.File_id);
        ImageInfo.numImages = size(ImageInfo.main, 1);
        ImageInfo.ImageWidth = ImageInfo.main(1).Width;
        ImageInfo.ImageHeight = ImageInfo.main(1).Height;

    else
        disp(['Do not support ', FileType, ' file'])
        return
    end

    if ImageInfo.numImages < 20
        disp('Warning, too short movie for tracking cell motion.')
    else
    end

    % Split the Tracking stacks

    if exist('TrackChannel', 'var')
        ImageInfo = StackSplitter(ImageInfo, ChannelNum, TrackChannel);
    else
        ImageInfo = StackSplitter(ImageInfo, ChannelNum);
    end

end
