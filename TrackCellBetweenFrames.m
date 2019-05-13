function [trace_result] = TrackCellBetweenFrames(center,cell_length,V,C)
size_center=size(center,2)-1;
trace_result=cell(0);

Barlength=0;
for i= 1:size_center
    Ci=C{i}; Vi=V{i}; centerx=center{i}(:,1); centery=center{i}(:,2);cell_length1=cell_length{i};
    centerx2=center{i+1}(:,1); centery2=center{i+1}(:,2);cell_length2=cell_length{i+1};
    size_Ci=size(Ci);
    for k = 1:size_Ci(1)
        in=inpolygon(centerx,centery,Vi(Ci{k},1),Vi(Ci{k},2));
        in2=inpolygon(centerx2,centery2,Vi(Ci{k},1),Vi(Ci{k},2));
        if sum(in)==1 && sum(in2)==1
            trace_result{i}{k}=[i,centerx(in),centery(in),cell_length1(in);i+1,centerx2(in2),centery2(in2),cell_length2(in2)];
        end
        
    end
    [~,Barlength] = DisplayBar(i,size_center,Barlength);
end
end

