function [Background_nor] = BackgroundNormalization(ImageInfo, varargin)

    Method = 'Fluorescent';
    
    if isempty(varargin)
    else

        for i = 1:(size(varargin, 2) / 2)
            AssignVar(varargin{i * 2 - 1}, varargin{i * 2})
        end

    end


    TrackImageIndex = ImageInfo.TrackImageIndex;
    File_id = ImageInfo.File_id;

    Background = [];
    ReSizeRatio = 3;

    if strcmp(ImageInfo.FileType, '.nd2')
        
        Num=1:(floor(size(TrackImageIndex, 2) / 20) + 1):size(TrackImageIndex, 2);
        [FilePointer,ImagePointer,ImageReadOut] = ND2Open(File_id);
        Background = ND2Read(FilePointer,ImagePointer,ImageReadOut,Num);
        ND2Close(FilePointer);
        clear('FilePointer');
    elseif strcmp(ImageInfo.FileType, '.tif')

        for i = 1:(floor(size(TrackImageIndex, 2) / 20) + 1):size(TrackImageIndex, 2)
            Original_Image = imread(File_id, 'Index', TrackImageIndex(i), 'Info', ImageInfo.main);
            Background(:, :, end + 1) = Original_Image;
        end

    else
        warning('Error')
        return
    end

    
    if strcmp(Method, 'Fluorescent')
        
    BG_mean = mean(double(Background), 3);
    BG_resize = imresize(BG_mean, 1 / ReSizeRatio, 'nearest');
    AdaptBG = adaptthresh(mat2gray(BG_resize,[0 max(BG_resize(:))]),0.5,'ForegroundPolarity','bright');
    
    [X, Y] = meshgrid(2:ReSizeRatio:ReSizeRatio*size(AdaptBG,2),2:ReSizeRatio:ReSizeRatio*size(AdaptBG,1));    
    [xData, yData, zData] = prepareSurfaceData(X, Y, AdaptBG);

    % Set up fittype and options.
    ft = fittype('a1.*(exp(-((x-b1).^2+(y-c1).^2)/d1^2))', 'independent', {'x', 'y'}, 'dependent', 'z');
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.Lower = [0 0 0 0];
    opts.Upper = [max(BG_resize(:))*2 ImageInfo.ImageWidth ImageInfo.ImageHeight 10000];
    opts.StartPoint = [max(BG_resize(:)) ImageInfo.ImageWidth/2 ImageInfo.ImageHeight/2 100];

    % Fit model to data.
    [fitBG, gof] = fit([xData, yData], zData, ft, opts);

    if gof.adjrsquare > 0.9
    else
        warning('off','backtrace')
        warning(['Fitting normalization background with RSquare of ', num2str(gof.adjrsquare)])
        warning('on','backtrace')
    end

    [X_BG, Y_BG] = meshgrid(1:ImageInfo.ImageWidth, 1:ImageInfo.ImageHeight);

    Background_nor = fitBG(X_BG, Y_BG) ./ (max(max(fitBG(X, Y))));

    elseif strcmp(Method, 'PhaseContrast')
    Background_nor =  median(double(Background), 3);
    end

    
end
