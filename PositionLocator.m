function [center,cell_size,V,C] = PositionLocator(CellRegion_All,ImageInfo)

center=cell(0); V=cell(0); C=cell(0); cell_size=cell(0);

for i = 1:size(CellRegion_All,2)
    
    center{i}=CellRegion_All{i}(:,2:3);
    cell_size{i}=CellRegion_All{i}(:,1);
    
    center{i}(end+1,:)=[floor(ImageInfo.ImageWidth*1/2),-floor(ImageInfo.ImageHeight*3/4)];
    center{i}(end+1,:)=[-floor(ImageInfo.ImageWidth*3/4),floor(ImageInfo.ImageHeight*1/2)];
    center{i}(end+1,:)=[floor(ImageInfo.ImageWidth*7/4),floor(ImageInfo.ImageHeight*1/2)];
    center{i}(end+1,:)=[floor(ImageInfo.ImageWidth*1/2),floor(ImageInfo.ImageHeight*7/4)];
    
    [V{i}, C{i}]=voronoin(center{i});
    
    C{i}(end-3:end)=[];
    center{i}(end-3:end,:)=[];

    DisplayBar(i,size(CellRegion_All,2));
end

end

