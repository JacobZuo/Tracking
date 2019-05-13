function [Background_nor] = BackgroundNormalization(ImageInfo)

    TrackImageIndex = ImageInfo.TrackImageIndex;
    File_id = ImageInfo.File_id;

    Background = [];
    ReSizeRatio = 3;

    if strcmp(ImageInfo.FileType, '.nd2')
        r = bfGetReader(File_id, 0);

        for i = 1:(floor(size(TrackImageIndex, 2) / 20) + 1):size(TrackImageIndex, 2)
            Original_Image = bfGetPlane(r, TrackImageIndex(i));
            Background(:, :, end + 1) = Original_Image;
        end

        r.close();
        clear r

    elseif strcmp(ImageInfo.FileType, '.tif')

        for i = 1:(floor(size(TrackImageIndex, 2) / 20) + 1):size(TrackImageIndex, 2)
            Original_Image = imread(File_id, 'Index', TrackImageIndex(i), 'Info', ImageInfo.main);
            Background(:, :, end + 1) = Original_Image;
        end

    else
        disp('Error')
        return
    end

    BG_mean = mean(double(Background), 3);
    BG_resize = imresize(BG_mean, 1 / ReSizeRatio, 'nearest');
    BG_blur = imgaussfilt(BG_resize, 5);
    [X, Y] = meshgrid(2:ReSizeRatio:ImageInfo.ImageHeight, 2:ReSizeRatio:ImageInfo.ImageWidth);

    [xData, yData, zData] = prepareSurfaceData(X, Y, BG_blur);

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
        disp(['Warning, fitting normalization background with RSquare of ', num2str(gof.adjrsquare)])
    end

    [X_BG, Y_BG] = meshgrid(1:ImageInfo.ImageHeight, 1:ImageInfo.ImageWidth);

    Background_nor = fitBG(X_BG, Y_BG) ./ (max(max(fitBG(X, Y))));

end
