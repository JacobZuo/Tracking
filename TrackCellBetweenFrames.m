function [trace_result] = TrackCellBetweenFrames(center, cell_size, cell_index, V, C)
    size_center = size(center, 2) - 1;
    trace_result = cell(0);

    for i = 1:size_center
        Ci = C{i}; Vi = V{i}; centerx = center{i}(:, 1); centery = center{i}(:, 2); cell_size1 = cell_size{i}; cell_index1 = cell_index{i};
        centerx2 = center{i + 1}(:, 1); centery2 = center{i + 1}(:, 2); cell_size2 = cell_size{i + 1}; cell_index2 = cell_index{i+1};
        size_Ci = size(Ci);

        for k = 1:size_Ci(1)
            in = inpolygon(centerx, centery, Vi(Ci{k}, 1), Vi(Ci{k}, 2));
            in2 = inpolygon(centerx2, centery2, Vi(Ci{k}, 1), Vi(Ci{k}, 2));

            if sum(in) == 1
                Cell_Distance = ((centerx2 - centerx(in)).^2 + (centery2 - centery(in)).^2).^0.5;

                if sum(in2) == 1
                    trace_result{i}{k} = [i, centerx(in), centery(in), cell_size1(in), cell_index1(in); i + 1, centerx2(in2), centery2(in2), cell_size2(in2), cell_index2(in2)];
                elseif sum(in2) ~= 1
                    NearestCellIndex = Cell_Distance == min(Cell_Distance);
                    if sum(NearestCellIndex) == 1
                        trace_result{i}{k} = [i, centerx(in), centery(in), cell_size1(in), cell_index1(in); i + 1, centerx2(NearestCellIndex), centery2(NearestCellIndex), cell_size2(NearestCellIndex), cell_index2(NearestCellIndex)];
                    else
                        trace_result{i}{k} = [];
                    end
                end
            else
%               disp('Warning!')
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
