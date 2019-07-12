function [ImageInfo] = CheckInfo(ImageInfo)
    warning('off','backtrace')
    MetadataStru = ImageInfo.metadata;
    ExperimentStru = ImageInfo.Experiment;

    Description = ImageInfo.description;
    Description(Description == 39) = [];
    Description(Description == 0) = ' ';

    DescriptionSplitIndex = find(Description == 13);

    DimensionsIndex = strfind(Description, 'Dimensions');

    Dimensions = Description(DimensionsIndex + 12:min(DescriptionSplitIndex(DescriptionSplitIndex > DimensionsIndex)) - 1);
    Dimensions(Dimensions == 120) = [];
    DimensionsCell = strsplit(Dimensions);

    for i = 1:size(DimensionsCell, 2)
        Dimensionsi = DimensionsCell{i};
        DimensionsStruct(i).name = Dimensionsi(1:find(Dimensionsi == 40) - 1);
        DimensionsStruct(i).Size = sscanf(Dimensionsi(find(Dimensionsi == 40):end), '(%d)');

        if isempty(DimensionsStruct(i).name)
            ChannelDimension = i;
        else
        end

    end
    
    if exist('ChannelDimension','var')
        DimensionsStruct(ChannelDimension) = [];
    else
    end
    
    ChannelNumIndex = strfind(Description, 'Planes');
    
    if isempty(ChannelNumIndex)
        ChannelNum = 1;
        ChannelIndex = max(strfind(Description, 'Name'));
        Channel.name = Description(ChannelIndex(i) + 6:min(DescriptionSplitIndex(DescriptionSplitIndex > ChannelIndex(i) + 5) - 1));
    else
        ChannelNum = str2double((Description(ChannelNumIndex + 8:min(DescriptionSplitIndex(DescriptionSplitIndex > ChannelNumIndex) - 1))));
        ChannelIndex = strfind(Description, 'Plane #');
        
        for i = 1:ChannelNum
            Channel(i).name = Description(ChannelIndex(i) + 18:min(DescriptionSplitIndex(DescriptionSplitIndex > ChannelIndex(i) + 18) - 1));
        end
    end
    
    if isempty(MetadataStru)
        warning('%s\n%s','Can not get Metadata.','Set channel infomation with ImageInfo.description.');
        
        MetadataStru.contents.channelCount = ChannelNum;

        for i = 1:ChannelNum
            MetadataStru.channels(i).channel.name = Channel(i).name;
        end

    else

        if MetadataStru.contents.channelCount == ChannelNum
        else
            warning('Channel number not match')
        end

        for i = 1:ChannelNum

            if strcmp(MetadataStru.channels(i).channel.name, Channel(i).name)
            else
                warning(['Channel ', num2str(i), ' name not match'])
            end

        end

    end

    if isempty(ExperimentStru)
        warning('%s\n%s','Can not get Experiment Info.','Set loops infomation with ImageInfo.description.');

        for i = 1:size(DimensionsStruct, 2)
            ExperimentStru(i,1).count = DimensionsStruct(i).Size;
            ExperimentStru(i,1).type = [DimensionsStruct(i).name, 'loop'];
        end

    else

        for i = 1:size(DimensionsStruct, 2)

            if contains(ExperimentStru(i).type, DimensionsStruct(i).name)
            else
                warning('%s\n%s',['Loop name not match in loop ', num2str(i), ', name ', ExperimentStru(i).type, ' vs ', DimensionsStruct(i).name, 'Loop.'], 'Set loops infomation with ImageInfo.description');
                ExperimentStru(i).type = [DimensionsStruct(i).name, 'loop'];
            end

            if ExperimentStru(i).count == DimensionsStruct(i).Size
            else
                warning('%s\n%s', ['Loop size not match in ', ExperimentStru(i).type, '.'], 'Set loops infomation with ImageInfo.description.')
                ExperimentStru(i).count = DimensionsStruct(i).Size;
            end

        end

    end

    if ImageInfo.CoordSize==size(ExperimentStru,1)
    else
        warning('%s\n%s', ['CoordSize not match.'], 'Set CoordSize infomation with ImageInfo.description.')   
        ImageInfo.CoordSize=size(ExperimentStru,1);
    end
    
    ImageCount=1;
    for i=1:size(ExperimentStru,1)
        ImageCount=ExperimentStru(i).count*ImageCount;
    end
    
    if ImageCount==ImageInfo.numImages
    else
        warning('Image number not match!!!');
        return
    end
    
    ImageInfo.metadata = MetadataStru;
    ImageInfo.Experiment = ExperimentStru;
    warning('on','backtrace')
end
