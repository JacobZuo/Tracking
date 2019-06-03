function [Percentage, Barlength] = DisplayBar(Index, Length)

    Percentage = Index / Length * 100;
    Barlength = floor(Index / Length * 60);

    if Index == 1
        fprintf('Processing [')
    else
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
    end

    if Barlength == 60

        for i = 1:60
            fprintf('#')
        end

    elseif Barlength >= 1

        for i = 1:(Barlength - 1)
            fprintf('#')
        end

        fprintf('>')
    end

    for i = 1:(60 - Barlength)
        fprintf('-')
    end

    fprintf(']%6.1f%%', Percentage)

    if Barlength == 60
        fprintf('\n')
    end

end
