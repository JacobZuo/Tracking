function [ImageInfo] = ND2Info(ImageInfo)

if not(libisloaded('Nd2ReadSdk'))
    [~,~]=loadlibrary('Nd2ReadSdk','Nd2ReadSdk.h');
end

FileName=ImageInfo.File_id;

FileID = libpointer('voidPtr',[int8(FileName) 0]);
[FilePointer] = calllib('Nd2ReadSdk','Lim_FileOpenForReadUtf8',FileID);
CoordSize = calllib('Nd2ReadSdk','Lim_FileGetCoordSize',FilePointer);
numImages = calllib('Nd2ReadSdk','Lim_FileGetSeqCount',FilePointer);
Attibutes = calllib('Nd2ReadSdk','Lim_FileGetAttributes',FilePointer);
setdatatype(Attibutes,'uint8Ptr',213)
AttibutesJson=strcat(string(char(Attibutes.Value')));
AttibutesStru=mps.json.decode(AttibutesJson);

ImageStru.uiBitsPerComp=AttibutesStru.bitsPerComponentInMemory;
ImageStru.uiComponents=AttibutesStru.componentCount;
ImageStru.uiWidthBytes=AttibutesStru.widthBytes;
ImageStru.uiHeight=AttibutesStru.heightPx;
ImageStru.uiWidth=AttibutesStru.widthPx;

ImageInfo.main = AttibutesStru;
ImageInfo.numImages = numImages;
ImageInfo.ImageWidth = ImageStru.uiWidth;
ImageInfo.ImageHeight = ImageStru.uiHeight;

calllib('Nd2ReadSdk','Lim_FileClose',FilePointer);

end
