function [BW_Image, CellRegion_array] = LocalMax(OriImage, varargin)

    if isempty(varargin)
        Range = 6;
        Tolerance = 'auto';
    elseif size(varargin, 2) == 1
        Range = 6;
        Tolerance = varargin{1};
    elseif size(varargin, 2) == 2
        Range = varargin{1};
        Tolerance = varargin{2};
    else
        warning('Error!')
        return
    end

    [LocalMaskX, LocalMaskY] = meshgrid(1:(Range * 2 - 1), 1:(Range * 2 - 1));
    LocalMask = ((LocalMaskX - Range).^2 + (LocalMaskY - Range).^2).^0.5 <= Range;

    if strcmp(Tolerance, 'auto')
        [OdrIntensity, ~] = sort(OriImage(:));
        Tolerance = OdrIntensity(floor(size(OdrIntensity, 1) * 19/20)) - median(OdrIntensity(1:floor(size(OdrIntensity, 1) * 3/10)));
    else
    end

    OriImageLocalMax = ordfilt2(OriImage, sum(LocalMask(:)), LocalMask);
    OriImageLocalMed = ordfilt2(OriImage, floor(sum(LocalMask(:)) / 2), LocalMask);

    BW_Image = (OriImage == OriImageLocalMax) & (OriImageLocalMax - OriImageLocalMed > Tolerance);

    se = strel('disk', min(floor(Range / 2), 3));
    BW_Image = imdilate(BW_Image, se);

    CellRegion = regionprops(BW_Image, OriImage, 'Area', 'WeightedCentroid');
    CellRegion_array = (reshape(struct2array(CellRegion), [3, size(CellRegion, 1)]))';

end
