function [ImageInfo] = StackSplitter(ImageInfo,ChannelNum,varargin)

if isempty(varargin)
else
    TrackChannel=varargin;
end

ImageIntensity=zeros(1,ChannelNum);


if exist('TrackChannel','var')
    if TrackChannel>ChannelNum
        ChannelNum=TrackChannel;
        disp('Warning ChannelNum should be larger than the channel index you want to track.')
        disp(['Set ChannelNum to ',num2str(ChannelNum),'!'])
    else
    end
    ImageInfo.TrackChannel=TrackChannel;
    ImageInfo.TrackImageIndex=ImageInfo.TrackChannel:ChannelNum:ImageInfo.numImages;
    
elseif ChannelNum==1
    ImageInfo.TrackChannel=1;
    ImageInfo.TrackImageIndex=1:ImageInfo.numImages;
else
    for i=1:ChannelNum
        if strcmp(ImageInfo.FileType,'.nd2')
            Original_Image=ND2ReadSingle(ImageInfo.FileName, i);
        elseif strcmp(ImageInfo.FileType,'.tif')
            Original_Image=imread(File_id,'Index',i,'Info',ImageInfo.main);
        else
            disp('Error!')
            return
        end
        ImageIntensity(i)=sum(Original_Image(:));
    end
    ImageInfo.TrackChannel=find(min(ImageIntensity));
    ImageInfo.TrackImageIndex=ImageInfo.TrackChannel:ChannelNum:ImageInfo.numImages;
end



end

