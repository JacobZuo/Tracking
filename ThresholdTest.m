function [BlurSize,ExtensionRatio,ActiveContourTimes] = ThresholdTest(ImageInfo,Background_nor)

File_id=ImageInfo.File_id;
TrackChannel=ImageInfo.TrackChannel;

if strcmp(ImageInfo.FileType,'.nd2')
    r = bfGetReader(File_id, 0);
    Original_Image=bfGetPlane(r, TrackChannel);
    r.close();
    clear r
elseif strcmp(ImageInfo.FileType,'.tif')
    Original_Image=imread(File_id,'Index',TrackChannel,'Info',ImageInfo.main);
end

Normalize_Image=uint16(double(Original_Image(:,:))./Background_nor);

BlurSize_test=0.5:0.5:3;
ExtensionRatio_test=1:1:8;

CellRegion_All=cell(0);
CellNumDetected=[];
NoiseNum=[];

Test_Index=0;
Barlength=0;

disp('----------------------------------------------------------------------------------------------------')
disp('Coarse tuning...')
for BlurSize_index=1:size(BlurSize_test,2)
    for ExtensionRatio_index=1:size(ExtensionRatio_test,2)
        [BW_Image] = BW_Single(Normalize_Image,BlurSize_test(BlurSize_index),ExtensionRatio_test(ExtensionRatio_index),'ActiveContourStatus','off');
        CellRegion=regionprops(BW_Image);
        Test_Index=Test_Index+1;
        CellRegion_All{BlurSize_index}{ExtensionRatio_index}=(reshape(struct2array(CellRegion), [7,size(CellRegion,1)]))';
        
        CellNumDetected(BlurSize_index,ExtensionRatio_index)=size(CellRegion,1);
        CellSize=CellRegion_All{BlurSize_index}{ExtensionRatio_index}(:,1);
        NoiseNum(BlurSize_index,ExtensionRatio_index)=sum(CellSize<5);
        
        [~,Barlength] = DisplayBar(Test_Index,size(BlurSize_test,2)*size(ExtensionRatio_test,2),Barlength);
    end
end

[BlurSize_better_Index,ExtensionRatio_better_Index]=find(CellNumDetected==max(CellNumDetected(NoiseNum<3)));

BlurSize_test_fine=(mean(BlurSize_test(BlurSize_better_Index))-0.2):0.1:(mean(BlurSize_test(BlurSize_better_Index))+0.2);
ExtensionRatio_test_fine=(mean(ExtensionRatio_test(ExtensionRatio_better_Index))-0.4):0.2:(mean(ExtensionRatio_test(ExtensionRatio_better_Index))+0.4);

CellRegion_All=cell(0);
CellNumDetected=[];
NoiseNum=[];

Test_Index=0;
Barlength=0;

disp('----------------------------------------------------------------------------------------------------')
disp('Fine tuning...')
for BlurSize_index=1:size(BlurSize_test_fine,2)
    for ExtensionRatio_index=1:size(ExtensionRatio_test_fine,2)
        [BW_Image] = BW_Single(Normalize_Image,BlurSize_test_fine(BlurSize_index),ExtensionRatio_test_fine(ExtensionRatio_index),'ActiveContourStatus','off');
        CellRegion=regionprops(BW_Image);
        Test_Index=Test_Index+1;
        CellRegion_All{BlurSize_index}{ExtensionRatio_index}=(reshape(struct2array(CellRegion), [7,size(CellRegion,1)]))';
        
        CellNumDetected(BlurSize_index,ExtensionRatio_index)=size(CellRegion,1);
        CellSize=CellRegion_All{BlurSize_index}{ExtensionRatio_index}(:,1);
        NoiseNum(BlurSize_index,ExtensionRatio_index)=sum(CellSize<5);
        
        [~,Barlength] = DisplayBar(Test_Index,size(BlurSize_test_fine,2)*size(ExtensionRatio_test_fine,2),Barlength);
    end
end

[BlurSize_best_Index,ExtensionRatio_best_Index]=find(CellNumDetected==max(CellNumDetected(NoiseNum<3)));

BlurSize=mean(BlurSize_test_fine(BlurSize_best_Index));
ExtensionRatio=mean(ExtensionRatio_test_fine(ExtensionRatio_best_Index));

disp('----------------------------------------------------------------------------------------------------')
disp('ActiveContour test...')
% TODO seprate activecountour test into DynamicActiveContour.m
CellSize_default=120;

[BW_Image] = BW_Single(Normalize_Image,BlurSize,ExtensionRatio,'ActiveContourStatus','off');
CellRegion=regionprops(BW_Image);
CellRegion_mat=(reshape(struct2array(CellRegion), [7,size(CellRegion,1)]))';
CellSize_Mean=mean(CellRegion_mat(:,1));

ActiveContourTimes=0;

while CellSize_Mean>CellSize_default
    ActiveContourTimes=ActiveContourTimes+1;
    [BW_Image]=BW_Single(Normalize_Image,BlurSize,ExtensionRatio,'ActiveContourTimes',ActiveContourTimes);
    CellRegion=regionprops(BW_Image);
    CellRegion_mat=(reshape(struct2array(CellRegion), [7,size(CellRegion,1)]))';
    CellSize_Mean=mean(CellRegion_mat(:,1));
end

imshow(BW_Image)

disp(['The BlurSize and ExtensionRatio is set as ',num2str(BlurSize),' and ',num2str(ExtensionRatio)])
disp(['The ActiveContourTimes is set as ',num2str(ActiveContourTimes)])

end