function [Image] = ND2ReadSingle(FileName,Num)

[FilePointer,ImagePointer,ImageReadOut] = ND2Open(FileName);
[Image] = ND2Read(FilePointer,ImagePointer,ImageReadOut,Num);
calllib('Nd2ReadSdk','Lim_FileClose',FilePointer);

end
