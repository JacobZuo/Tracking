function [Image] = ND2ReadSingle(FileName, varargin)

[FilePointer, ImagePointer, ImageReadOut] = ND2Open(FileName);

if isempty(varargin)
    numImages = calllib('Nd2ReadSdk', 'Lim_FileGetSeqCount', FilePointer);
    Num=1:numImages;
else
    Num=varargin{1};
end

[Image] = ND2Read(FilePointer, ImagePointer, ImageReadOut, Num);
calllib('Nd2ReadSdk', 'Lim_FileClose', FilePointer);

end
