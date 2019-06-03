function [Trace_all] = TraceConnector(trace_result)

    Trace_all = trace_result{1};
    Trace_all(cellfun('length', Trace_all) == 0) = [];

    Tracking_id = cell(1, 10000);
    Tracking_id{2} = 1:max(size(Trace_all));
    size_trace_result = size(trace_result, 2);

    for i = 2:size_trace_result

        for h = Tracking_id{i}
            k = 1;

            while (k <= max(size(trace_result{i})))

                if ~isempty(trace_result{i}{k})

                    if trace_result{i}{k}(1, :) == Trace_all{h}(end, :)
                        Trace_all{h}(end + 1, :) = trace_result{i}{k}(2, :);
                        trace_result{i}{k} = [];
                        Tracking_id{i + 1}(end + 1) = h;
                        break
                    else
                        k = k + 1;
                    end

                else
                    k = k + 1;
                end

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
