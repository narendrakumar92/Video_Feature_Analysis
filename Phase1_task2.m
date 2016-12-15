flag=0;
count=0;
prompt = 'Please enter the directory path containing videos: ';
npath = input(prompt,'s');

prompt = 'What is the resolution? ';
nres = input(prompt)



prompt = 'What will be your outputfile name ';
oFile = input(prompt,'s');




Files=dir(npath);
for k=3:length(Files)
  
    FileNames=Files(k).name;
[pathstr,name,ext] = fileparts(FileNames);
inputVideo = VideoReader(FileNames);

for img =1:inputVideo.NumberOfFrames
    indFrame = read(inputVideo,img);
    fname = strcat('frame',num2str(img));
   
    grayimage = rgb2gray(indFrame);


[rows, columns, numberOfColorBands] = size(grayimage);


RowSize = nres;
ColSize = nres;
%Gets the no of cell blocks - row
blockRows = floor(rows/RowSize);
%Gets the no of cell blocks - row
blockCols = floor(columns/ColSize);
       
       [f,d] = sift(grayimage);
       
      colzsize = size(f,2);
for r = [blockRows:blockRows:rows]
for c = [blockCols:blockCols:columns]
      
      
       for val = 1: colzsize
          fads = f(:, [val]);
          dads = d(:, [val]);
          
          ex = fads(1,1);
          ey = fads(2,1);
if (((ex > (r - blockRows)) && ex <= r) && ((ey > (c - blockCols)) && ey <= c))

      fid=fopen(oFile,'a');
            count = count+1;
            fprintf(fid,'\n<%s;%d;(%d,%d);[',FileNames,img,(r/blockRows)-1,(c/blockCols)-1);
            fprintf(fid,[repmat('%f,', 1, size(fads, 2)) ], fads');
           % fprintf(fid,'];');
            fprintf(fid,[repmat('%f,', 1, size(dads, 2))], dads');
            fprintf(fid,']>');
fclose(fid);
end
       end
      
end
      
end
end
end
