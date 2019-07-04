function [Trace_Trimmed] = TraceTrimmer(Trace_All, varargin)
    MaxSpeed=20;
    if isempty(varargin)
        Trace_length_min = 0;
    else
        Trace_length_min = cell2mat(varargin);
    end

    Trace_length_all = cellfun(@length, Trace_All);
    Trace_All = Trace_All(Trace_length_all > Trace_length_min + 1);
    
    Trace_All_Trimmed = cell(0);

    for i = 1:size(Trace_All, 2)
        CellSize = Trace_All{i}(:, 4);
        CellSpeed = [0; ((Trace_All{i}(2:end, 2)-Trace_All{i}(1:end-1, 2)).^2+(Trace_All{i}(2:end, 3)-Trace_All{i}(1:end-1, 3)).^2).^0.5];
        Index = find(CellSize < mean(CellSize) * 0.2 | CellSize > mean(CellSize) * 1.8 | CellSpeed > MaxSpeed);

        if isempty(Index)
            Trace_All_Trimmed{end + 1} = Trace_All{i};

        else
            Trace_All{i}(Index, :) = [];
            SeprateIndex = find(diff(Trace_All{i}(:, 1)) ~= 1);

            if isempty(SeprateIndex)
                Trace_All_Trimmed{end + 1} = Trace_All{i};
            else
                SeprateIndex(2:end + 1) = SeprateIndex;
                SeprateIndex(1) = 0;
                SeprateIndex(end + 1) = size(Trace_All{i}, 1);

                for k = 1:(size(SeprateIndex, 2) - 1)

                    if SeprateIndex(k) + 1 == SeprateIndex(k + 1)
                    else
                        Trace_All_Trimmed{end + 1} = Trace_All{i}(SeprateIndex(k) + 1:SeprateIndex(k + 1), :);
                    end

                end

            end

        end

        Trace_length = cellfun(@length, Trace_All_Trimmed);
        Trace_Trimmed = Trace_All_Trimmed(Trace_length > Trace_length_min + 1);

    end
