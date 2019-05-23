function [] = ND2Close(FilePointer)

calllib('Nd2ReadSdk','Lim_FileClose',FilePointer);

end

