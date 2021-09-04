TemplateAudioParentPath='C:\Users\XINDONG\Desktop\Piano';
SourceAudioPath='C:\Users\XINDONG\Desktop\CanKillMyHorse.wav';
PlayFrequency=4;
MinFrequencyAmplitude=0.1;
MinStartAmplitude = 0.02;

TemplateAudioFiles=dir(fullfile(TemplateAudioParentPath,'*.wav'));
TemplateAudioNames={TemplateAudioFiles.name};
TemplateAudioNum=size(TemplateAudioNames,2);
TemplateAudioArray=[];

[Wave,Fs]=audioread(SourceAudioPath);
SourceAudio.Wave=Wave;
SourceAudio.Fs=Fs;
SourceAudio.Size=length(SourceAudio.Wave);

DeltaSize=Fs/PlayFrequency;

% for i=1:TemplateAudioNum
for i=1:1
    TemplateAudioName=TemplateAudioFiles(i).name;
    TemplateAudioPath=[TemplateAudioParentPath,'\',TemplateAudioName];
    
    [Wave,Fs]=audioread(TemplateAudioPath);
    StartIdx=[0;0];
    StartIdx(1,1)=find(abs(Wave(10:end,1))>=MinStartAmplitude,1) + 9;
    StartIdx(2,1)=find(abs(Wave(10:end,2))>=MinStartAmplitude,1) + 9;
    
    StartIdx=min(StartIdx);
    
    Wave=Wave(StartIdx:StartIdx+DeltaSize-1,1:2);

    N=DeltaSize;
    RawFFTData=fft(Wave);
    Fa=abs(RawFFTData)*2/N;
    Fa=Fa(1:floor(N/2),1:2);
    F=transpose((0:N-1)*(Fs/N));
    F=F(1:floor(N/2));
    
    [MainFrequencyAmplitude,MainFrequencyIdx]=max(Fa);
    MainFrequencyAmplitude=transpose(MainFrequencyAmplitude);
    MainFrequency=F(MainFrequencyIdx);
    
    TemplateAudio.Name=TemplateAudioName;
    TemplateAudio.Wave=Wave;
    TemplateAudio.Fs=Fs;
    TemplateAudio.Fa=Fa;
    TemplateAudio.F=F;
    TemplateAudio.MainFrequencyAmplitude=MainFrequencyAmplitude;
    TemplateAudio.MainFrequency=MainFrequency;
%     
%     TemplateAudioArray=[TemplateAudioArray,TemplateAudio];
end


% TemplateMainFrequency=[TemplateAudioArray.MainFrequency];
% [SortedTemplateMainFrequency, SortedTemplateMainFrequencyIdx]=sort(TemplateMainFrequency);
% 
% TempTemplateAudioArray=TemplateAudioArray;
% 
% for i=1:length(TemplateAudioArray)
%     TemplateAudioArray(i)=TempTemplateAudioArray(SortedTemplateMainFrequencyIdx(i));
% end
% 
% % DiffFre=[];
% % 
% % for i=1:length(TemplateAudioArray)-1
% %     DiffFre=[DiffFre,abs(TemplateAudioArray(i+1).MainFrequency-TemplateAudioArray(i).MainFrequency)];
% % end
% 
OutputAudioWave=[];
% 
% for i=1:SourceAudio.Size/DeltaSize
for i=1:1
    for j=1:length(TemplateAudioArray)
        TemplateAudioArray(j).MaxPlayAmplitudeRate = [0;0];
    end
    
    PartAudioWave=SourceAudio.Wave((i-1)*DeltaSize+1:i*DeltaSize,1:2);

    [N,C]=size(PartAudioWave);
    RawFFTData=fft(Wave);
    Fa=abs(RawFFTData)*2/N;
    Fa=Fa(1:floor(N/2),1:2);
    F=transpose((0:N-1)*(Fs/N));
    F=F(1:floor(N/2));
    
    FindTable=find(Fa>=MinFrequencyAmplitude);
%     
% %     for j=1:length(FindColumn)
% %         for k=1:length(FindRow)
% %             CurrentFrequency=F(FindRow(k),1);
% %             CurrentFrequencyAmplitude=Fa(FindRow(k),FindColumn(j));
% %             
% %             [~,MostClosedIdx]=min(abs([TemplateAudioArray.MainFrequency]-CurrentFrequency));
% %             Weight=CurrentFrequencyAmplitude/TemplateAudioArray(MostClosedIdx).MainFrequencyAmplitude(k,j);
% %             
% %             TemplateAudioArray(MostClosedIdx).MaxPlayAmplitudeRate(k,j)=max(TemplateAudioArray(MostClosedIdx).MaxPlayAmplitudeRate(k,j), Weight);
% %         end
% %     end
% 
%     TempOutputAudioWave=zeros(DeltaSize,2);
% %     for j=1:2
% %        for k= 1:length(TempOutputAudioWave)
% %            TempOutputAudioWave(1:end,j)=TempOutputAudioWave(1:end,j)+TemplateAudioArray(k).MaxPlayAmplitudeRate(k,j)*TemplateAudioArray(k).Wave()
% %        end
% %     end
%     
%     FindTable=[FindRow,FindColumn];
%     
%     [RowNum,ColunmNum]=size(FindTable);
%     for j=1:RowNum
% %         CurrentFrequency=F(FindTable(j,1),1);
% %         CurrentFrequencyAmplitude=Fa(FindTable(j,1),FindTable(j,2));
% %         
% %         [~,MostClosedIdx]=min(abs([TemplateAudioArray.MainFrequency]-CurrentFrequency));
%     end
%     
end
plot(F,Fa)