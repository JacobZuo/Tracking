function [ImageInfo, BW_Image] = BWInfo(BW_Image_File)

    if ischar(BW_Image_File)
        [Path, FileName, Type] = fileparts(BW_Image_File);
        
        if strcmp(Type, '.mat')
            BW_Image_Stru=load(BW_Image_File);
            BW_Image=cell2mat(struct2cell(BW_Image_Stru));
            
            if exist('ImageInfo', 'var')
            else
                ImageInfo.Path = [Path, '\'];
                ImageInfo.FileName = FileName;
                ImageInfo.numImages = size(BW_Image, 3);
                ImageInfo.ImageWidth = size(BW_Image, 2);
                ImageInfo.ImageHeight = size(BW_Image, 1);
            end
            
        elseif strcmp(Type, '.tif')
            
            BW_Image = BW_Image_File;
            
            if exist('ImageInfo', 'var')
            else
                ImageInfo.main = imfinfo(BW_Image_File);
                ImageInfo.Path = [Path, '\'];
                ImageInfo.FileName = FileName;
                ImageInfo.numImages = size(ImageInfo.main, 1);
                ImageInfo.ImageWidth = ImageInfo.main(1).Width;
                ImageInfo.ImageHeight = ImageInfo.main(1).Height;
            end
        end
    else
        BW_Image = BW_Image_File;
        if exist('ImageInfo', 'var')
        else
            ImageInfo.Path = [pwd, '\'];
            ImageInfo.FileName = char(datetime('now', 'format', 'yyyy-MM-dd-HH-mm-ss'));
            ImageInfo.numImages = size(BW_Image, 3);
            ImageInfo.ImageWidth = size(BW_Image, 2);
            ImageInfo.ImageHeight = size(BW_Image, 1);
        end
    end

end

