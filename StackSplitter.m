function [ImageInfo] = StackSplitter(ImageInfo,ChannelNum,varargin)

if isempty(varargin)
else
    TrackChannel=cell2mat(varargin{1});
end

ImageIntensity=zeros(1,ChannelNum);


if exist('TrackChannel','var')
    if TrackChannel>ChannelNum
        ChannelNum=TrackChannel;
        warning('off','backtrace')
        warning('%s\n%s', 'ChannelNum should be larger than the channel index you want to track.', ['Set ChannelNum to ',num2str(ChannelNum),'!'])
        warning('on','backtrace')
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
            r = bfGetReader(ImageInfo.File_id, 0);
            Original_Image=bfGetPlane(r, i);
            r.close();
            clear r
        elseif strcmp(ImageInfo.FileType,'.tif')            
            Original_Image=imread(ImageInfo.File_id,'Index',i,'Info',ImageInfo.main);
        end
        ImageIntensity(i)=sum(Original_Image(:));
    end
    ImageInfo.TrackChannel=find(min(ImageIntensity));
    ImageInfo.TrackImageIndex=ImageInfo.TrackChannel:ChannelNum:ImageInfo.numImages;
end



end

