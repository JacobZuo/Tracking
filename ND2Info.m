function [ImageInfo] = ND2Info(FileName)

if not(libisloaded('Nd2ReadSdk'))
    [~,~]=loadlibrary('Nd2ReadSdk','Nd2ReadSdk.h');
end

FileID = libpointer('voidPtr',[int8(FileName) 0]);

[FilePointer] = calllib('Nd2ReadSdk','Lim_FileOpenForReadUtf8',FileID);

% CoordSize = calllib('Nd2ReadSdk','Lim_FileGetCoordSize',FilePointer);
numImages = calllib('Nd2ReadSdk','Lim_FileGetSeqCount',FilePointer);
Attibutes = calllib('Nd2ReadSdk','Lim_FileGetAttributes',FilePointer);
setdatatype(Attibutes,'uint8Ptr',500)
AttibutesValue=Attibutes.Value';
Attibuteslength=find(AttibutesValue==0,1);
AttibutesJson=char(AttibutesValue(1:Attibuteslength-1));
AttibutesStru=mps.json.decode(AttibutesJson);

numImages = calllib('Nd2ReadSdk','Lim_FileGetSeqCount',FilePointer);
CoordSize = calllib('Nd2ReadSdk','Lim_FileGetCoordSize',FilePointer);

Metadata = calllib('Nd2ReadSdk','Lim_FileGetMetadata',FilePointer);
setdatatype(Metadata,'uint8Ptr',5000)
MetadataValue=Metadata.Value';
Metadatalength=find(MetadataValue==0,1);
MetadataJson=char(MetadataValue(1:Metadatalength-1));

ImageInfo.metadata = MetadataJson;
ImageInfo.numImages = numImages;
ImageInfo.CoordSize = CoordSize;
ImageInfo.ImageWidth = AttibutesStru.widthPx;
ImageInfo.ImageHeight = AttibutesStru.heightPx;
ImageInfo.Component = AttibutesStru.componentCount;
calllib('Nd2ReadSdk','Lim_FileClose',FilePointer);

end
