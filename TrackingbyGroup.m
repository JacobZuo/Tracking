%% find the path
filePath=dir('Y:\data\20190628\*.mat');

%% modify the path parameters for different computer 
for ii=1:36
    filePath=dir('Y:\data\20190628\*.mat');
    load([filePath(ii).folder,'\',filePath(ii).name]);
    FileName=[filePath(ii).folder,'\',ImageInfo.FileName,ImageInfo.FileType];
    ImageInfo.File_id=FileName;
    ImageInfo.Path=[filePath(1).folder,'\'];
    clear('filePath');
    save([ImageInfo.Path, 'modify Trace ', ImageInfo.FileName, '.mat'])
    clear;
end

%% tracking by group
for ii=17:19
   dbstop if error
   filePath=dir('Y:\data\20190705\*.nd2');
   Tracking([filePath(ii).folder,'\',filePath(ii).name],'Normalization', 'off');
end


