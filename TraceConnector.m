function [Trace_all] = TraceConnector(trace_result)

    Trace_all = trace_result{1};
    Trace_all(cellfun('length', Trace_all) == 0) = [];

    Tracking_id = cell(1, 10000);
    Tracking_id{2} = 1:max(size(Trace_all));
    size_trace_result = size(trace_result, 2);

    for i = 2:size_trace_result
        trace_result_mat = cell2mat(trace_result{i}');
        trace_result_start = trace_result_mat(1:2:end,:);
        for h = Tracking_id{i}
            trace_connect_index = find(trace_result_start(:,5) == Trace_all{h}(end, 5),1);            
            if ~isempty(trace_connect_index)                
                Trace_all{h}(end + 1, :) = trace_result{i}{trace_connect_index}(2, :);
                trace_result{i}{trace_connect_index} = [];
                Tracking_id{i + 1}(end + 1) = h;
                
            else
            end
            
        end


        trace_result{i}(cellfun('length', trace_result{i}) == 0) = [];

        if ~isempty(trace_result{i})
            size_trace_resulti = size(trace_result{i});
            Trace_all(end + 1:end + size_trace_resulti(2)) = trace_result{i};
            Tracking_id{i + 1}(end + 1:end + size_trace_resulti(2)) = (max(size(Trace_all)) - size_trace_resulti(2) + 1):max(size(Trace_all));
        end

        DisplayBar(i - 1, size_trace_result - 1);
    end

end
