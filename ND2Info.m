function [ImageInfo] = ND2Info(FileName)

    if not(libisloaded('Nd2ReadSdk'))
        [~, ~] = loadlibrary('Nd2ReadSdk', 'Nd2ReadSdk.h');
    end

    FileID = libpointer('voidPtr', [int8(FileName) 0]);
    [FilePointer] = calllib('Nd2ReadSdk', 'Lim_FileOpenForReadUtf8', FileID);
    numImages = calllib('Nd2ReadSdk', 'Lim_FileGetSeqCount', FilePointer);
    CoordSize = calllib('Nd2ReadSdk', 'Lim_FileGetCoordSize', FilePointer);
    Attibutes = calllib('Nd2ReadSdk', 'Lim_FileGetAttributes', FilePointer);
    setdatatype(Attibutes, 'uint8Ptr', 500)
    AttibutesValue = Attibutes.Value';
    Attibuteslength = find(AttibutesValue == 0, 1);
    AttibutesJson = char(AttibutesValue(1:Attibuteslength - 1));
    AttibutesStru = jsondecode(AttibutesJson);

    Metadata = calllib('Nd2ReadSdk', 'Lim_FileGetMetadata', FilePointer);
    TestLength=3000;
    setdatatype(Metadata, 'uint8Ptr', TestLength)
    MetadataValue = Metadata.Value';
    while isempty(find(MetadataValue == 0, 1))
        TestLength=TestLength*2;
        setdatatype(Metadata, 'uint8Ptr', TestLength)
        MetadataValue = Metadata.Value';
    end
    Metadatalength = find(MetadataValue == 0, 1);
    MetadataJson = char(MetadataValue(1:Metadatalength - 1));
    MetadataStru = jsondecode(MetadataJson);
    
    TextInfo = calllib('Nd2ReadSdk', 'Lim_FileGetTextinfo', FilePointer);
    TestLength=3000;
    setdatatype(TextInfo, 'uint8Ptr', TestLength)
    TextInfoValue = TextInfo.Value';
    while isempty(find(TextInfoValue == 0, 1))
        TestLength=TestLength*2;
        setdatatype(TextInfo, 'uint8Ptr', TestLength)
        TextInfoValue = TextInfo.Value';
    end
    TextInfolength = find(TextInfoValue == 0, 1);
    TextInfoJson = char(TextInfoValue(1:TextInfolength - 1));
    TextInfoStru = jsondecode(TextInfoJson);
    
    Experiment = calllib('Nd2ReadSdk', 'Lim_FileGetExperiment', FilePointer);
    TestLength=3000;
    setdatatype(Experiment, 'uint8Ptr', TestLength)
    ExperimentValue = Experiment.Value';
    while isempty(find(ExperimentValue == 0, 1))
        TestLength=TestLength*2;
        setdatatype(Experiment, 'uint8Ptr', TestLength)
        ExperimentValue = Experiment.Value';
    end
    Experimentlength = find(ExperimentValue == 0, 1);
    ExperimentJson = char(ExperimentValue(1:Experimentlength - 1));
    ExperimentStru=jsondecode(ExperimentJson);
    
    
    NumInCoord=zeros(1,CoordSize);
    for i = 1:CoordSize
        NumInCoord(i)=ExperimentStru(i).count;
    end
    
%     for i=1:CoordSize
%         TypeBuffer = libpointer('voidPtr',int8('unknown'));
%         NumInCoord(i) = calllib('Nd2ReadSdk', 'Lim_FileGetCoordInfo', FilePointer,uint8(i-1),TypeBuffer,10); 
%     end
    
    ImageInfo.metadata = MetadataStru;
    ImageInfo.Experiment = ExperimentStru;
    ImageInfo.capturing = TextInfoStru.capturing;
    ImageInfo.description = TextInfoStru.description;
    ImageInfo.numImages = numImages;
    ImageInfo.CoordSize = CoordSize;
    
    ImageInfo.NumInCoord = NumInCoord;
    ImageInfo.ImageWidth = AttibutesStru.widthPx;
    ImageInfo.ImageHeight = AttibutesStru.heightPx;
    ImageInfo.Component = AttibutesStru.componentCount;
    
    disp(['There are ', num2str(numImages*MetadataStru.contents.channelCount), ' images in ', num2str(MetadataStru.contents.channelCount), ' channel(s).'])
    
    for i = 1:MetadataStru.contents.channelCount
        disp(['The No. ', num2str(i), ' channel is: ', MetadataStru.channels(i).channel.name])
    end
    
    disp(['Images are captured in ', num2str(size(ExperimentStru,1)), ' layer(s) of loops'])
    
    for i = 1:size(ExperimentStru,1)
        disp(['The No. ', num2str(i-1), ' layer is: ', num2str(ExperimentStru(i).count), ' ', ExperimentStru(i).type])
    end
    
    calllib('Nd2ReadSdk', 'Lim_FileClose', FilePointer);

end
