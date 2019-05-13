function [Percentage, Barlength] = DisplayBar(Index, Length, Barlength)
    % TODO write a introduction

    if Index == 1
        disp('--------10%-------20%-------30%-------40%-------50%-------60%-------70%-------80%-------90%---------')
    else
    end

    Percentage = Index / Length * 100;

    if Percentage - Barlength < 1
    else

        for i = 1:floor(Percentage - Barlength)
            fprintf('>')
            Barlength = Barlength + 1;
        end

    end

    if Barlength == 100
        fprintf('\n')
    else
    end

end
