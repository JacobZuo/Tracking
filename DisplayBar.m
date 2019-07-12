function [Percentage, Barlength] = DisplayBar(Index, Length)

    Percentage = Index / Length * 100;
    Barlength = floor(Index / Length * 60);

    if Index == 1
        tic;
        BarStart='';
        TimeSpend=toc;
    else
        BarStart = repmat('\b',1,161);
        TimeSpend=toc;
    end

    if Barlength == 60
        BarText=['Finished!  [', repmat('#',1,60),sprintf(']%6.1f', Percentage),'%%'];
    elseif Barlength >= 1
        BarText=['Processing [', repmat('#',1,(Barlength - 1)),'>',repmat('-',1,(60 - Barlength)),sprintf(']%6.1f', Percentage),'%%'];
    else
        BarText=['Processing [', repmat('-',1,(60 - Barlength)),sprintf(']%6.1f', Percentage),'%%'];
    end
    
    if Barlength == 60
        TimeSpendText=['Time Used: ', datestr(seconds(TimeSpend),'HH:MM:SS'),' s', '\n'];
    else
        TimeSpendText=['Time Used: ', datestr(seconds(TimeSpend),'HH:MM:SS'),' s',repmat(' ',1,10), 'Time Remained: ', datestr(seconds((TimeSpend/Percentage*100)-TimeSpend),'HH:MM:SS'),' s', repmat(' ',1,24)];
    end
    
    fprintf([BarStart, BarText, '\n', TimeSpendText])

end
