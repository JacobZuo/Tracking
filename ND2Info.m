function [ImageInfo] = ND2Info(FileName)

if not(libisloaded('Nd2ReadSdk'))
    [~, ~] = loadlibrary('Nd2ReadSdk', 'Nd2ReadSdk.h');
end

FileID = libpointer('voidPtr', [int8(FileName) 0]);
[FilePointer] = calllib('Nd2ReadSdk', 'Lim_FileOpenForReadUtf8', FileID);
numImages = calllib('Nd2ReadSdk', 'Lim_FileGetSeqCount', FilePointer);
CoordSize = calllib('Nd2ReadSdk', 'Lim_FileGetCoordSize', FilePointer);
Attributes = calllib('Nd2ReadSdk', 'Lim_FileGetAttributes', FilePointer);
setdatatype(Attributes, 'int8Ptr', 500)
AttributesValue = Attributes.Value';
Attributeslength = find(AttributesValue == 0, 1);
AttributesJson = char(AttributesValue(1:Attributeslength - 1));
AttributesStru = jsondecode(AttributesJson);

TextInfo = calllib('Nd2ReadSdk', 'Lim_FileGetTextinfo', FilePointer);
TestLength=3000;
setdatatype(TextInfo, 'int8Ptr', TestLength)
TextInfoValue = TextInfo.Value';
while isempty(find(TextInfoValue == 0, 1))
    TestLength=TestLength*2;
    setdatatype(TextInfo, 'int8Ptr', TestLength)
    TextInfoValue = TextInfo.Value';
end
TextInfolength = find(TextInfoValue == 0, 1);
TextInfoJson = char(TextInfoValue(1:TextInfolength - 1));
TextInfoStru = jsondecode(TextInfoJson);

Metadata = calllib('Nd2ReadSdk', 'Lim_FileGetMetadata', FilePointer);

if Metadata.isNull
    MetadataStru=[];
else
    TestLength=3000;
    setdatatype(Metadata, 'int8Ptr', TestLength)
    MetadataValue = Metadata.Value';
    while isempty(find(MetadataValue == 0, 1))
        TestLength=TestLength*2;
        setdatatype(Metadata, 'int8Ptr', TestLength)
        MetadataValue = Metadata.Value';
    end
    Metadatalength = find(MetadataValue == 0, 1);
    MetadataJson = char(MetadataValue(1:Metadatalength - 1));
    MetadataStru = jsondecode(MetadataJson);
    
end


Experiment = calllib('Nd2ReadSdk', 'Lim_FileGetExperiment', FilePointer);
if Experiment.isNull
    ExperimentStru=[];
    NumInCoord=[];
else
    TestLength=3000;
    setdatatype(Experiment, 'int8Ptr', TestLength)
    ExperimentValue = Experiment.Value';
    while isempty(find(ExperimentValue == 0, 1))
        TestLength=TestLength*2;
        setdatatype(Experiment, 'int8Ptr', TestLength)
        ExperimentValue = Experiment.Value';
    end
    Experimentlength = find(ExperimentValue == 0, 1);
    ExperimentJson = char(ExperimentValue(1:Experimentlength - 1));
    ExperimentStru=jsondecode(ExperimentJson);
    
    
    NumInCoord=zeros(1,CoordSize);
    for i = 1:CoordSize
        NumInCoord(i)=ExperimentStru(i).count;
    end
    
end

ImageInfo.metadata = MetadataStru;
ImageInfo.Experiment = ExperimentStru;
ImageInfo.capturing = TextInfoStru.capturing;
ImageInfo.description = TextInfoStru.description;
ImageInfo.numImages = numImages;
ImageInfo.CoordSize = CoordSize;

% ImageInfo.NumInCoord = NumInCoord;

if AttributesStru.widthBytes==AttributesStru.widthPx*AttributesStru.componentCount*AttributesStru.bitsPerComponentInMemory/8
    ImageInfo.ImageWidth = AttributesStru.widthPx;
    ImageInfo.ImageWidthOriginal = AttributesStru.widthPx;
else
    disp('Warning, image width is not fit the bytes of width. Reset image width.')
    ImageInfo.ImageWidth=AttributesStru.widthBytes/AttributesStru.componentCount/(AttributesStru.bitsPerComponentInMemory/8);
    ImageInfo.ImageWidthOriginal = AttributesStru.widthPx;
end



ImageInfo.ImageHeight = AttributesStru.heightPx;
ImageInfo.Component = AttributesStru.componentCount;


[ImageInfo] = CheckInfo(ImageInfo);
PrintInfo(ImageInfo);

ND2Close(FilePointer)

end
