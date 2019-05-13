function [ ] = SpecialCaseDetector(CellRegion,Normalize_Image,BW_Image,Path,FrameNum)

CellRegionMat=(reshape(struct2array(CellRegion), [7, size(CellRegion, 1)]))';

CellSize=CellRegionMat(:,1);
CellX1=CellRegionMat(:,4);
CellY1=CellRegionMat(:,5);
CellWidth=CellRegionMat(:,6);
CellHeight=CellRegionMat(:,7);

X1=CellX1(CellSize>mean(CellSize)*2);
Y1=CellY1(CellSize>mean(CellSize)*2);
X2=CellWidth(CellSize>mean(CellSize)*2);
Y2=CellHeight(CellSize>mean(CellSize)*2);

for i=1:size(X1,1)
    
    OriginalImageCut=Normalize_Image(floor(Y1(i)):(floor(Y1(i))+Y2(i)+1),floor(X1(i)):(floor(X1(i))+X2(i))+1);
    BWImageCut=BW_Image(floor(Y1(i)):(floor(Y1(i))+Y2(i)+1),floor(X1(i)):(floor(X1(i))+X2(i))+1);
    imwrite(OriginalImageCut, [Path,'SpecialCase\',num2str(FrameNum), '\Original_', num2str(i), '.tif'], 'WriteMode', 'overwrite', 'Compression', 'none');
    imwrite(BWImageCut, [Path,'SpecialCase\',num2str(FrameNum), '\BW_', num2str(i), '.tif'], 'WriteMode', 'overwrite', 'Compression', 'none');
    
end





end

