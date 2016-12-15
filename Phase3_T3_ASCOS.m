%tmp and ind has most significant frames sorted
%tmp 2nd and 3rd col has videofile and frame no


prompt={'Enter value for M:',...
    'Enter the K value (Similar frames)',...
    'Enter the inputfile path from task 2',...
    'Enter the output directory to visualize',...
    };
dlg_title='Input for Task 3';
num_lines=1;
default={'10','2','C:\Users\naren\Desktop\Phase3\out_file_10_2.spc','C:\Users\naren\Desktop\SUBMIT P3\Task 3 Visual\'}; %need to change if someother laptpo
input=inputdlg(prompt,dlg_title,num_lines,default);
Kvalue=str2num(input{2});
inputfile=input{3};
outputfile=input{4};


Ma = str2num(input{1});
%Ma=10;
fileID=fopen(inputfile);
cellsFromFile = textscan(fileID,['{<%f,%f>,<%f,%f>,%f}']);
Rawdata = cell2mat(cellsFromFile); 
Predata = Rawdata(:,1);
startindex = 1;
 maxvideocount = max(Rawdata(:,1));
 endindex=0;
 k=Kvalue;

            
            
for videoiter = 1:maxvideocount
video_filtered = Rawdata(Rawdata(:, 1) == videoiter, :);
[row col] = size(video_filtered);
row = row/k;
endindex = endindex+row;
newmat(videoiter,1)  = startindex;
newmat(videoiter,2) = endindex;
startindex = endindex+1;

end


Matchdata = Rawdata(:,[3:4]);
[totrow totcol] = size(Rawdata);
T = zeros(totrow/k);
S = zeros(totrow/k);
hashvalue = 1/k;



for i = 1:totrow
    colval = newmat(Rawdata(i, 3),1)+Rawdata(i, 4)-1;
    Matchdata(i,3) = colval;
    rowval = newmat(Rawdata(i, 1),1)+Rawdata(i, 2)-1;
    Rawdata(i,6) = rowval;
    Rawdata(i,7) = colval;
    T(rowval,colval) = 1;
   S(rowval,colval) = Rawdata(i,5);
end
out=sum(T,1)  

[rowi coli] = size(T);
Totalframes = max(Rawdata(:,6));
 ODimension = [1:Totalframes];
 ODimension = transpose(ODimension);

for coliter = 1:coli
   for rowiter = 1:rowi
    if T(rowiter,coliter) == 1 
        
        for inneriter = 1:rowi
            if T(inneriter,rowiter) ==1 && rowiter ~= coliter
                 S(rowiter,coliter) = 0.85/out(1,rowiter) * S(inneriter,coliter);
            else
                S(rowiter,coliter) = 1;
            end
        end
        
       
    end
   end
end


out1=sum(S,1) 
outtranspose = transpose(out1);
 value.OLD = ODimension;
 value.SCORE = outtranspose;
[tmp ind]=sort(value.SCORE,'descend'); %tmp and ind has proper values, printing this values



comptemp = zeros(Totalframes,1);
itercount = 2;
%test for convergence
while tmp(1,1) - comptemp(1,1) > power(1/10,itercount)
    
   itercount = itercount+1;
comptemp = tmp(1:Totalframes,1);
for coliter = 1:coli
   for rowiter = 1:rowi
    if T(rowiter,coliter) == 1 
        sum1 = 0;
        for inneriter = 1:rowi
            if T(inneriter,rowiter) ==1 && rowiter ~= coliter
                sum1 = sum1 + S(inneriter,coliter);
                 S(rowiter,coliter) = 0.85/out(1,rowiter) * sum1;
            else
                S(rowiter,coliter) = 1;
            end
        end
        
       
    end
   end
end


out1=sum(S,1) 
outtranspose = transpose(out1);
 value.OLD = ODimension;
 value.SCORE = outtranspose;
[tmp ind]=sort(value.SCORE,'descend'); %tmp and ind has proper values, printing this values
difft = tmp-comptemp;
end




for s = 1:Totalframes
    for vdata = 1:maxvideocount
        if ind(s,1) >= newmat(vdata,1) && ind(s,1)<= newmat(vdata,2)
            tmp(s,2) = vdata;
            tmp(s,3) = ind(s,1)-newmat(vdata,1)+1;
            
        end
    end
end


M = tmp([1:Ma],:);



dirPath = 'C:\Videos\';
dirFiles = strcat(dirPath,'\*.mp4');
listVideoFiles=dir(dirFiles);
videoName = strcat(outputfile,'finalvid_ASCOS','.mp4');
writerObj = VideoWriter(videoName);
writerObj.FrameRate = 1;
open(writerObj);
            
for p = 1 : Ma
    for q = 1 : length(listVideoFiles)
        if ( M(p,2) == q )
            videoFileName=listVideoFiles(q).name;
            fprintf('Video in which sequence matched: %s\n',videoFileName);
            videoFrames= VideoReader(strcat(dirPath,videoFileName));
            similarFrameSeqStart = M(p,3);
           % similarFrameSeqEnd = M(p,3);
            % to create a video sequence
            secsPerImage = [5 10 15];
            currentFrameGray=rgb2gray(read(videoFrames,similarFrameSeqStart));
            imwrite(currentFrameGray,['Image_ASCOS' int2str(p), '.jpg']);
            writeVideo(writerObj, currentFrameGray);
           % end;
            
        end;
    end;
end;
close(writerObj);
