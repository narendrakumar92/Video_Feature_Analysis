%tmp and ind has most significant frames sorted
%tmp 2nd and 3rd col has videofile and frame no


prompt={'Enter value for M:',...
    'Enter the K value (Similar frames)',...
    'Enter the inputfile path from task 2',...
    'Enter the output directory to visualize',...
     'Enter the Seed1 Video ,range : 1-63',...
      'Enter the Seed1 frame number',...
       'Enter the Seed2 Video ,range : 1-63',...
        'Enter the Seed2 frame number',...
         'Enter the Seed3 Video ,range : 1-63',...
          'Enter the Seed3 frame number',...
    };
dlg_title='Input for Task 3';
num_lines=1;
default={'10','2','C:\Users\naren\Desktop\Phase3\out_file_10_2.spc','C:\Users\naren\Desktop\SUBMIT P3\Task 3 Visual\','22','24','47','11','6','16'}; %need to change if someother laptpo
input=inputdlg(prompt,dlg_title,num_lines,default);
Kvalue=str2num(input{2});
inputfile=input{3};
outputfile=input{4};

%seed
seedv1=str2num(input{5});
seedf1=str2num(input{6});
seedv2=str2num(input{7});
seedf2=str2num(input{8});
seedv3=str2num(input{9});
seedf3=str2num(input{10});

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
hashvalue = 1/k;


for i = 1:totrow
    colval = newmat(Rawdata(i, 3),1)+Rawdata(i, 4)-1;
    Matchdata(i,3) = colval;
    rowval = newmat(Rawdata(i, 1),1)+Rawdata(i, 2)-1;
    Rawdata(i,6) = rowval;
    Rawdata(i,7) = colval;
    T(rowval,colval) = Rawdata(i,5);
   
end

Totalframes = max(Rawdata(:,6));

 ODimension = [1:Totalframes];
 ODimension = transpose(ODimension);

T = transpose(T);

P(1:Totalframes,1) = 1/Totalframes;

alpha = 0.85;

%in matlab page :  r = (1-P)/n + P*(A'*(r./d) + s/n);  , s- node with 0
%edges, s = 0 in our case

firsthalf = zeros(Totalframes,1);

framevid(1,1) = seedv1;
framevid(1,2) = seedf1;
framevid(2,1) = seedv2;
framevid(2,2) = seedf2;
framevid(3,1) = seedv3;
framevid(3,2) = seedf3;
%we need to add weightage for the adjacent nodes of the given 3 nodes
%and we need to add weightage for the given nodes as well taking self loops





for i = 1:3

    
    framevidval = newmat(framevid(i, 1),1)+framevid(i, 2)-1;
    framevid(i,3) = framevidval;
    %seeded nodes alone will have 1/3 , others are zero as per the paper
   firsthalf(framevidval,1) = 1/3; %seeded nodes are 3 as per the question so 1/3
   P(framevidval,1) = P(framevidval,1) + 1/(k+1) ; %considering self loops 
   %it is the summation of randomwalk and teleportation contribution for S
   %nodes
end

    %to find the adjacent nodes
    adjnodes_filtered = Rawdata(Rawdata(:, 1) == framevid(1,1) & Rawdata(:, 2) == framevid(1,2) | Rawdata(:, 1) == framevid(2,1) & Rawdata(:, 2) == framevid(2,2) | Rawdata(:, 1) == framevid(3,1) & Rawdata(:, 2) == framevid(3,2), :);
    
    [adjrow adjcol] = size(adjnodes_filtered);
    
    
    %it is the summation of randomwalk and teleportation contribution for
    %S's adjacent nodes
    for adji = 1:adjrow
        nframevidval = adjnodes_filtered(adji,7);
        P(nframevidval,1) = P(nframevidval,1) + 1/(k+1);
    end
    
    
    

Prod = firsthalf + alpha*(T*(P/k)); %gives the frame's significance


%Prod = (alpha*(T*P)) + ((1-alpha)*P);


 value.OLD = ODimension;
 value.SCORE = Prod;
[tmp ind]=sort(value.SCORE,'descend'); %tmp and ind has proper values, printing this values



comptemp = zeros(Totalframes,1);

itercount = 2;
%test for convergence
while tmp(1,1) - comptemp(1,1) > power(1/10,itercount)
 
   itercount = itercount+1;
   comptemp = tmp(1:Totalframes,1);
Prod = firsthalf + alpha*(T*(P/k)); %gives the frame's significance
%Prod = (alpha*(T*P)) + ((1-alpha)*P);
value.OLD = ODimension;
 value.SCORE = Prod;
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
videoName = strcat(outputfile,'finalvid_PPR','.mp4');
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
              imwrite(currentFrameGray,['Image_PPR' int2str(p), '.jpg']);
            writeVideo(writerObj, currentFrameGray);
           % end;
            
        end;
    end;
end;
close(writerObj);