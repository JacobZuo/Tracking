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
    [ImageX, ImageY] = meshgrid(1:size(OriImage,1),1:size(OriImage,2));
    LocalMask = ((LocalMaskX - Range).^2 + (LocalMaskY - Range).^2).^0.5 <= Range;
    ImageMask = ((ImageX - Range).^2 + (ImageY - Range).^2).^0.5 < Range;
    ImageMaskIndex = find(ImageMask == 1);
    IndexImage=reshape(1:(size(OriImage,1)*size(OriImage,2)),size(OriImage));
    Index=find(IndexImage==IndexImage(Range, Range));

    if strcmp(Tolerance, 'auto')
        [OdrIntensity, ~] = sort(OriImage(:));
        Tolerance = OdrIntensity(floor(size(OdrIntensity, 1) * 97.5/100)) - median(OdrIntensity(1:floor(size(OdrIntensity, 1) * 50/100)));
    else
    end

    OriImageLocalMax = imdilate(OriImage, LocalMask);
    
    LocalMaxIndex = find(OriImageLocalMax==OriImage);
    LocalMaxMatrix = LocalMaxIndex+(ImageMaskIndex-Index)';
    LocalMaxIndexMatrix = LocalMaxIndex+(ImageMaskIndex-Index)';
    LocalMaxMatrix(LocalMaxMatrix<min(IndexImage(:)) | LocalMaxMatrix>max(IndexImage(:)))=1;
    
    LocalImageMatrix=reshape(OriImage(LocalMaxMatrix(:)),size(LocalMaxMatrix));
    LocalImageMatrix(LocalMaxIndexMatrix<min(IndexImage(:)) | LocalMaxIndexMatrix>max(IndexImage(:)))=NaN;
    
    LocalMedian=median(LocalImageMatrix,2,'omitnan');

%     OriImageLocalMed = medfilt2(OriImage, [(Range * 2 - 1), (Range * 2 - 1)]);

    OriImageLocalMed=OriImage;
    OriImageLocalMed(LocalMaxIndex)=LocalMedian;


    BW_Image = (OriImage == OriImageLocalMax) & (OriImageLocalMax - OriImageLocalMed > Tolerance);
    
    se = strel('disk', min(floor(Range / 2), 5));
    BW_Image = imdilate(BW_Image, se);

    CellRegion = regionprops(BW_Image, OriImage, 'Area', 'WeightedCentroid');
    CellRegion_array = (reshape(struct2array(CellRegion), [3, size(CellRegion, 1)]))';

end
