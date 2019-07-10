function [] = ND2Close(FilePointer)

    if exist('FilePointer','var')
        calllib('Nd2ReadSdk', 'Lim_FileClose', FilePointer);
        clear('FilePointer')
    else
    end
end

