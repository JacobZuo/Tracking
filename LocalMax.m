function [BW_Image] = LocalMax(OriImage,Size,Tolerance)

mask = ones(Size*2-1);
% mask(Size, Size) = 0;

OriImageLocalMax=ordfilt2(OriImage, (Size*2-1)^2, mask);
OriImageLocalMin=ordfilt2(OriImage, ((Size*2-1)^2+1)/2, mask);

BW_Image = (OriImage==OriImageLocalMax) & (OriImageLocalMax-OriImageLocalMin>Tolerance);

se = strel('square', 3);
BW_Image=imdilate(BW_Image,se);

end

