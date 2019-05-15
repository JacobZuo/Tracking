function [Trace_All, ImageInfo] = Tracking(FileName, varargin)
    %
    % [Trace_All, ImageInfo] = Tracking(FileName)
    % [Trace_All, ImageInfo] = Tracking(FileName, 'Parameter', value)
    %
    % Tracking(FileName) tracking the fluorescent cells in movie (.nd2 or .tif) of file name
    % of 'FileName'.
    %
    % The funtion will return a cell data Trace_All and a structure data ImageInfo. Each cell
    % in Trace_All will be one trajectories in the movie. The rest tracking result will be
    % saved in '.mat' file in the same path.
    %
    % Multichannel images is acceptable.
    % [Trace_All, ImageInfo] = Tracking(FileName, 'ChannelNum', 2)
    % will automatically split the stack into 2 channels. The darkest channel will be taken as
    % the fluorescent channel for tracking.
    %
    % [Trace_All, ImageInfo] = Tracking(FileName, 'AutoThreshold', 'off', 'BlurSize', 1.5, ...
        %   'ExtensionRatio', 2, 'ActiveContourTimes', 5)
    % will set the thereshold manually. You can find the specific introduction for each parameter in
    % README.md.
    %

    % TODO Test the .tif support.
    % TODO SpecialCaseDetector.

    % Initialization the default parameter
    disp('----------------------------------------------------------------------------------------------------')
    disp('Initialization...')

    ChannelNum = 1;
    Normalization = 'on';
    AutoThreshold = 'on';
    AutoCellSize = 'on';
    ActiveContourStatus = 'off';
    ActiveContourTimes = 5;
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

    % Check the Information of the movie

    if exist('TrackChannel', 'var')
        ImageInfo = ImageFileInfo(FileName, ChannelNum, TrackChannel);
    else
        ImageInfo = ImageFileInfo(FileName, ChannelNum);
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
        disp('----------------------------------------------------------------------------------------------------')
        disp('Auto threshold tesing')
        [BlurSize, ExtensionRatio] = ThresholdTest(ImageInfo, Background_nor);
    else

        if exist('BlurSize', 'var')
        else
            BlurSize = 1.5;
        end

        if exist('ExtensionRatio', 'var')
        else
            ExtensionRatio = 2;
        end

    end

    disp(['The BlurSize and ExtensionRatio is set as ', num2str(BlurSize), ' and ', num2str(ExtensionRatio)])

    % Process Cell Size.
    disp('----------------------------------------------------------------------------------------------------')
    disp('Process Cell Size')
    MeanCellSize = CellSizeTest(ImageInfo, Background_nor, BlurSize, ExtensionRatio, 'AutoCellSize', AutoCellSize, 'ActiveContourStatus', ActiveContourStatus, 'ActiveContourTimes', ActiveContourTimes);
    disp(['The mean cell size is about ', num2str(MeanCellSize)])

    % Transform the gray images into B/W image
    disp('----------------------------------------------------------------------------------------------------')
    disp('B/W Image Calculating...')
    [CellRegion_All, ~] = BW_All(ImageInfo, Background_nor, BlurSize, ExtensionRatio, 'CellSizeControlStatus', AutoCellSize, 'ActiveContourStatus', 'on', 'ActiveContourTimes', ActiveContourTimes);

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
