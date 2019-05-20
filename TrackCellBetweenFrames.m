function [trace_result] = TrackCellBetweenFrames(center,cell_size,V,C)
size_center=size(center,2)-1;
trace_result=cell(0);

Barlength=0;
for i= 1:size_center
    Ci=C{i}; Vi=V{i}; centerx=center{i}(:,1); centery=center{i}(:,2);cell_size1=cell_size{i};
    centerx2=center{i+1}(:,1); centery2=center{i+1}(:,2);cell_size2=cell_size{i+1};
    size_Ci=size(Ci);
    for k = 1:size_Ci(1)
        in=inpolygon(centerx,centery,Vi(Ci{k},1),Vi(Ci{k},2));
        in2=inpolygon(centerx2,centery2,Vi(Ci{k},1),Vi(Ci{k},2));
        if sum(in)==1
            Cell_Distance = ((centerx2-centerx(in)).^2+(centery2-centery(in)).^2).^0.5;
            if sum(in2)==1
                trace_result{i}{k}=[i,centerx(in),centery(in),cell_size1(in);i+1,centerx2(in2),centery2(in2),cell_size2(in2)];
            elseif sum(in2)~=1
                NearestCellIndex=Cell_Distance==min(Cell_Distance);
                trace_result{i}{k}=[i,centerx(in),centery(in),cell_size1(in);i+1,centerx2(NearestCellIndex),centery2(NearestCellIndex),cell_size2(NearestCellIndex)];
            end
        else
            % disp('Warning!')
        end
    end
    [~,Barlength] = DisplayBar(i,size_center,Barlength);
end
end

