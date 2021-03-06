TemplateAudioParentPath='D:\GitSpace\AudioSimulator\Piano';
SourceAudioPath='D:\GitSpace\AudioSimulator\CanKillMyHorse.wav';
PlayFrequency=20;%把播放频率改为每秒20下，高质量还原你的DNA
MinFrequencyAmplitude=0;
MinStartAmplitude = 0.02;
OutputAudioScale=0.1

TemplateAudioFiles=dir(fullfile(TemplateAudioParentPath,'*.wav'));
TemplateAudioNames={TemplateAudioFiles.name};
TemplateAudioNum=size(TemplateAudioNames,2);
TemplateAudioArray=[];

[Wave,Fs]=audioread(SourceAudioPath);
SourceAudio.Wave=Wave;
SourceAudio.Fs=Fs;
SourceAudio.Size=length(SourceAudio.Wave);

DeltaSize=Fs/PlayFrequency;

for i=1:TemplateAudioNum
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

    TemplateAudioArray=[TemplateAudioArray,TemplateAudio];
end

OutputAudioWave=[];

for i=1:floor(SourceAudio.Size/DeltaSize)
    for j=1:length(TemplateAudioArray)
        TemplateAudioArray(j).MaxPlayAmplitudeRate = [0;0];
    end
    
    PartAudioWave=SourceAudio.Wave((i-1)*DeltaSize+1:i*DeltaSize,1:2);

    [N,C]=size(PartAudioWave);
    RawFFTData=fft(PartAudioWave);
    Fa=abs(RawFFTData)*2/N;
    Fa=Fa(1:floor(N/2),1:2);
    F=transpose((0:N-1)*(Fs/N));
    F=F(1:floor(N/2));
    
    [FindRow,FindColumn]=find(Fa>=MinFrequencyAmplitude);
    FindTable=[FindRow,FindColumn];
    [RowNum,ColumnNum]=size(FindTable);
    
    for j=1:RowNum
        CurrentFrequencyAmplitude=Fa(FindTable(j,1),FindTable(j,2));
        CurrentFrequency=F(FindTable(j,1));
        
        TempAudioFrequencp=[TemplateAudioArray.MainFrequency];
        [~,MostClosedIdx]=min(abs(TempAudioFrequencp(FindTable(j,2),1:end)-CurrentFrequency));
        
        Weight=CurrentFrequencyAmplitude/TemplateAudioArray(MostClosedIdx).MainFrequencyAmplitude(FindTable(j,2),1);
        MaxWeight=max(Weight,TemplateAudioArray(MostClosedIdx).MaxPlayAmplitudeRate(FindTable(j,2),1));
        TemplateAudioArray(MostClosedIdx).MaxPlayAmplitudeRate(FindTable(j,2),1)=MaxWeight;
    end
    
    ParOutputAudio=0;
    for j=1:length(TemplateAudioArray)
        LeftChannel=TemplateAudioArray(j).MaxPlayAmplitudeRate(1,1)*TemplateAudioArray(j).Wave(1:end,1);
        RightChannel=TemplateAudioArray(j).MaxPlayAmplitudeRate(2,1)*TemplateAudioArray(j).Wave(1:end,2);
        ParOutputAudio=ParOutputAudio+[LeftChannel,RightChannel];
    end
    OutputAudioWave=[OutputAudioWave;ParOutputAudio];
end
OutputAudioWave=OutputAudioScale*OutputAudioWave;
sound(OutputAudioWave,Fs)