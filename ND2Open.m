function [FilePointer,ImagePointer,ImageReadOut] = ND2Open(FileName)

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
ImagePointer = libpointer('s_LIMPICTUREPtr', ImageStru);

calllib('Nd2ReadSdk','Lim_InitPicture',ImagePointer,ImageStru.uiWidth,ImageStru.uiHeight,ImageStru.uiBitsPerComp,ImageStru.uiComponents);

[~,~,ImageReadOut] = calllib('Nd2ReadSdk','Lim_FileGetImageData',FilePointer,uint32(0),ImagePointer);
setdatatype(ImageReadOut.pImageData,'uint16Ptr',ImageStru.uiWidth*ImageStru.uiHeight)

end