function [BW_Image] = BW_Single(Normalize_Image, BlurSize, ExtensionRatio, varargin)

    ActiveContourStatus = 'off';
    AutoCellSize = 120;
    ActiveContourTimes = 5;

    if isempty(varargin)
    else

        for i = 1:(size(varargin, 2) / 2)
            AssignVar(varargin{i * 2 - 1},varargin{i * 2})
        end

    end

    if BlurSize == 0
        Iblur = Normalize_Image;
    else
        Iblur = imgaussfilt(Normalize_Image, BlurSize);
    end

    [A, B] = hist(Normalize_Image(:), 0:1/255:1);
    [xData, yData] = prepareCurveData(B, A);
    ft = fittype('gauss1');
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.Lower = [0 0 0];
    opts.StartPoint = [max(A) mean(double(Normalize_Image(:))) std(double(Normalize_Image(:)))];
    [fitresult, gof] = fit(xData, yData, ft, opts);

    if gof.adjrsquare > 0.98
    else
        assignin('caller', 'Warning', 1)
    end

    BW_Image = (Iblur > fitresult.b1 + ExtensionRatio * fitresult.c1);
    
    if strcmp(AutoCellSize, 'off')
    else
        [BW_Image, ~] = CellSizeControl(BW_Image, AutoCellSize);
    end

    if strcmp(ActiveContourStatus, 'on')
        BW_Image = activecontour(Normalize_Image, BW_Image, ActiveContourTimes, 'edge');
    else
    end

end
