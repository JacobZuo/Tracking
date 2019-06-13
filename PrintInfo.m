function [] = PrintInfo(ImageInfo)

MetadataStru=ImageInfo.metadata;
ExperimentStru=ImageInfo.Experiment;


if isempty(MetadataStru)
    disp(['There are ', num2str(ImageInfo.numImages*ImageInfo.Component), ' images in ', num2str(ImageInfo.Component), ' channel(s).'])
    disp('The channel infomation is listed in ImageInfo.description -> Plane Name')
else
    disp(['There are ', num2str(ImageInfo.numImages*MetadataStru.contents.channelCount), ' images in ', num2str(MetadataStru.contents.channelCount), ' channel(s).'])
    
    for i = 1:MetadataStru.contents.channelCount
        disp(['The No. ', num2str(i), ' channel is: ', MetadataStru.channels(i).channel.name])
    end
end


if isempty(ExperimentStru)
    disp('The loop infomation is listed in ImageInfo.description -> Dimensions')
else
    disp(['Images are captured in ', num2str(size(ExperimentStru,1)), ' layer(s) of loops'])
    
    for i = 1:size(ExperimentStru,1)
        disp(['The No. ', num2str(i-1), ' layer is: ', num2str(ExperimentStru(i).count), ' ', ExperimentStru(i).type])
    end
end



end

