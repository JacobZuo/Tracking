function [Trace_All, ImageInfo] = Tracking(FileName, varargin)
    %
    % Tracking(Path,FileName)
    %
    % Tracking(Path,FileName) tracking the fluorescent cells in image (.nd2) of file name of 'FileName' in path 'Path'. The tracking result is saved in '.mat' file with the same name of 'FileName' in 'Path'.
    %
    % The tracking is based on a B/W image. The fluorescent image (gray) is transformed into B/W image after normalization with some adjustable parameters. The image is 'blur' with a 'gauss filter' in radias as 'BlurSize'. The threshold is adjusted with parameters of the histogram of the background (peak value and peak width). Increasing the parameter 'ExtensionRatio' will icrease the threshold.
    %
    % Multichannel images is acceptable. Change 'ChannelNum' will splite the images into several channels one and another. The darkest channel will be taken as the fluorescent channel for tracking.
    %
    % One can use either one or more parameters in the same command. For example, Tracking(Path,FileName,'ChannelNum',2) will split the images into 2 channels. The default parameters is set as below.
    %
    %                 ChannelNum=1;
    %                 ImagePlay='on';
    %                 AutoThreshold,'on'
    %
    % AutoThreshold controls the auto threshold detection. Set 'AutoThreshold' 'off' and then user can past the threshold parameters with BlurSize and ExtensionRatio. The default setting is shown below.
    %
    %                 BlurSize=1.5;
    %                 ExtensionRatio=2;
    %                 ActiveContourTimes = 3;


    % TODO Test the .tif support.
    % TODO TrackPlayer Play the trojactories in a movie (tif stack)
    % TODO SpecialCaseDetector and use activecontour to resolve the problem.

    % Initialization the default parameter
    disp('----------------------------------------------------------------------------------------------------')
    disp('Initialization...')

    ChannelNum = 1;
    AutoThreshold = 'on';
    Normalization = 'on';

    % Reload the parameters input by user

    if isempty(varargin)
    else
        for i = 1:(size(varargin, 2) / 2)
            if ischar(varargin{i * 2})
                eval([varargin{i * 2 - 1}, ' = ''', varargin{i * 2}, '''; ']);
            else
                eval([varargin{i * 2 - 1}, '=', num2str(varargin{i * 2}), ';']);
            end
        end
    end

    % Check the frame number of the images

    ImageInfo = ImageFileInfo(FileName);

    % Split the Tracking stacks

    if exist('TrackChannel', 'var')
        ImageInfo = StackSplitter(ImageInfo, ChannelNum, TrackChannel);
    else
        ImageInfo = StackSplitter(ImageInfo, ChannelNum);
    end

    % Background Normalization

    if strcmp(Normalization, 'on')
        disp('----------------------------------------------------------------------------------------------------')
        disp('Background normalization...')
        Background_nor = BackgroundNormalization(ImageInfo);
    else
        disp('----------------------------------------------------------------------------------------------------')
        disp('Background normalization off')
        Background_nor = ones(ImageInfo.ImageHeight, ImageInfo.ImageWidth);
    end

    % Test for the best threshold.
    if strcmp(AutoThreshold, 'on')
        [BlurSize, ExtensionRatio, ActiveContourTimes] = ThresholdTest(ImageInfo, Background_nor);
    else
        
        if exist('BlurSize', 'var')
        else
            BlurSize = 1.5;
        end

        if exist('ExtensionRatio', 'var')
        else
            ExtensionRatio = 2;
        end

        if exist('ActiveContourTimes', 'var')
        else
            ActiveContourTimes = 3;
        end

    end

    % Transform the gray images into B/W image
    disp('----------------------------------------------------------------------------------------------------')
    disp('B/W Image Calculating...')
    [CellRegion_All, ~] = BW_All(ImageInfo, Background_nor, BlurSize, ExtensionRatio, ActiveContourTimes);

    % PartOne find the locations of cells
    disp('----------------------------------------------------------------------------------------------------')
    disp('Finding cells locations ...')
    [Cell_Centroid, Cell_Size, V, C] = PositionLocator(CellRegion_All, ImageInfo);

    disp('Finished!')

    % PartTwo link the cells between neighbour frames
    disp('----------------------------------------------------------------------------------------------------')
    disp('Tracking cells between neighbour frames')
    [trace_result] = TrackCellBetweenFrames(Cell_Centroid, Cell_Size, V, C);

    disp('Finished!')

    % PartThree connect all the traces
    disp('----------------------------------------------------------------------------------------------------')
    disp('Connect cells traces')
    [Trace_All] = TraceConnector(trace_result);

    disp('Finished!')
    disp('----------------------------------------------------------------------------------------------------')
    disp('Saving data!')
    clear('i')

    disp('----------------------------------------------------------------------------------------------------')
    save([ImageInfo.Path, 'Trace ', ImageInfo.FileName, '.mat'])

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%    @@   @@  @@   @@   @@        @@    @@@@@                             %
%    @@ @ @@  @@   @@   @@       @@@@   @@  @@       Wu Lab at CUHK       %
%    @@ @ @@  @@   @@   @@      @@  @@  @@  @@     All rights reserved    %
%    @@ @ @@  @@   @@   @@      @@  @@  @@@@@   www.phy.cuhk.edu.hk/ylwu  %
%     @@@@@   @@   @@   @@      @@@@@@  @@  @@                            %
%     @@ @@   @@   @@   @@   @  @@  @@  @@  @@    J. Z.: zwlong@live.com  %
%     @@ @@    @@@@@    @@@@@@  @@  @@  @@@@@                             %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%          @@@@   @@  @@  @@  @@  @@  @@                                  %
%         @@  @@  @@  @@  @@  @@  @@ @@              Wu Lab at CUHK       %
%         @@      @@  @@  @@  @@  @@@@             All rights reserved    %
%         @@      @@  @@  @@@@@@  @@@           www.phy.cuhk.edu.hk/ylwu  %
%         @@      @@  @@  @@  @@  @@@@                                    %
%         @@  @@  @@  @@  @@  @@  @@ @@           J. Z.: zwlong@live.com  %
%          @@@@    @@@@   @@  @@  @@  @@                                  %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%        @@@@    @@     @@@@    @@@@   @@@@@                              %
%         @@    @@@@   @@  @@  @@  @@  @@  @@        Wu Lab at CUHK       %
%         @@   @@  @@  @@      @@  @@  @@  @@      All rights reserved    %
%         @@   @@  @@  @@      @@  @@  @@@@@    www.phy.cuhk.edu.hk/ylwu  %
%         @@   @@@@@@  @@      @@  @@  @@  @@                             %
%     @@  @@   @@  @@  @@  @@  @@  @@  @@  @@     J. Z.: zwlong@live.com  %
%      @@@@    @@  @@   @@@@    @@@@   @@@@@                              %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
