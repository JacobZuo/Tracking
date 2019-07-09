function [trace_result] = TrackCellBetweenFrames(center, cell_size, cell_index, V, C)

    size_center = size(center, 2) - 1;
    trace_result = cell(0);

    for i = 1:size_center
        Ci = C{i}; Vi = V{i}; centerx = center{i}(:, 1); centery = center{i}(:, 2); cell_size1 = cell_size{i}; cell_index1 = cell_index{i};
        centerx2 = center{i + 1}(:, 1); centery2 = center{i + 1}(:, 2); cell_size2 = cell_size{i + 1}; cell_index2 = cell_index{i+1};
        size_Ci = size(Ci);
        
        for k = 1:size_Ci(1)
            CellinPolyIndex = inpolygon(centerx2, centery2, Vi(Ci{k}, 1), Vi(Ci{k}, 2));
            
            Cell_Distance = ((centerx2 - centerx(k)).^2 + (centery2 - centery(k)).^2).^0.5;
            
            if sum(CellinPolyIndex) == 1
                trace_result{i}{k} = [i, centerx(k), centery(k), cell_size1(k), cell_index1(k); i + 1, centerx2(CellinPolyIndex), centery2(CellinPolyIndex), cell_size2(CellinPolyIndex), cell_index2(CellinPolyIndex)];
            elseif sum(CellinPolyIndex) ~= 1
                NearestCellIndex = Cell_Distance == min(Cell_Distance);
                if sum(NearestCellIndex) == 1
                    trace_result{i}{k} = [i, centerx(k), centery(k), cell_size1(k), cell_index1(k); i + 1, centerx2(NearestCellIndex), centery2(NearestCellIndex), cell_size2(NearestCellIndex), cell_index2(NearestCellIndex)];
                else
                    trace_result{i}{k} = [];
                end
            end
        end
        
        %     find repeat connections
        trace_result{i}(cellfun('length', trace_result{i}) == 0) = [];

        trace_repeat_test = cell2mat(trace_result{i}(:));
        CellSpeed = ((trace_repeat_test(2:2:end, 2) - trace_repeat_test(1:2:end, 2)).^2 + (trace_repeat_test(2:2:end, 3) - trace_repeat_test(1:2:end, 3)).^2).^0.5;

        
        trace_repeat_test_index = trace_repeat_test(2:2:end, 5);
        [Sort_trace_repeat_test_index,SortIndex]=sortrows(trace_repeat_test_index);
        RepeatIndex = find(diff(Sort_trace_repeat_test_index) == 0);

        while ~isempty(RepeatIndex)
            DelIndex = (RepeatIndex + double((CellSpeed(SortIndex(RepeatIndex)) - CellSpeed(SortIndex(RepeatIndex + 1))) < 0));
            trace_result{i}(SortIndex(DelIndex)) = [];
            trace_repeat_test = cell2mat(trace_result{i}(:));
            CellSpeed = ((trace_repeat_test(2:2:end, 2) - trace_repeat_test(1:2:end, 2)).^2 + (trace_repeat_test(2:2:end, 3) - trace_repeat_test(1:2:end, 3)).^2).^0.5;
            trace_repeat_test_index = trace_repeat_test(2:2:end, 5);
            [Sort_trace_repeat_test_index,SortIndex]=sortrows(trace_repeat_test_index);
            RepeatIndex = find(diff(Sort_trace_repeat_test_index) == 0);
        end
        DisplayBar(i, size_center);
    end

end
