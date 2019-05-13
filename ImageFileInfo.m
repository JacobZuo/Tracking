function [Info] = ImageFileInfo(FileName)
    %  TODO for tif image stack add
    [Path,Name,Type] = fileparts(FileName);
    Info.File_id = FileName;
    Info.Path = [Path,'\'];
    Info.FileName = Name;
    Info.FileType = Type;

    if strcmp(Info.FileType, '.nd2')

        r = bfGetReader(Info.File_id, 0);
        Info.main = r.getGlobalMetadata();
        Info.numImages = r.getImageCount();
        Info.ImageWidth = r.getSizeX();
        Info.ImageHeight = r.getSizeY();
        r.close();
        clear r

    elseif strcmp(Info.FileType, '.tif')

        Info.main = imfinfo(Info.File_id);
        Info.numImages = size(Info.main, 1);
        Info.ImageWidth = Info.main(1).Width;
        Info.ImageHeight = Info.main(1).Height;

    else
        disp(['Do not support ', FileType, ' file'])
        return
    end

    if Info.numImages < 20
        disp('Warning, too short movie for tracking cell motion.')
    else
    end

end
