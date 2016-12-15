prompt = 'Please enter the directory path containing videos: ';
npath = input(prompt,'s');

prompt = 'What is the resolution? ';
nres = input(prompt)

prompt = 'What is the histogram size? ';
nbin = input(prompt)

prompt = 'What will be your outputfile name ';
oFile = input(prompt,'s')

%outputFile = strcat(oFile,'.txt')

%https://www.mathworks.com/matlabcentral/answers/33103-divide-256-256-image-into-4-4-blocks
%Referred the above link to understand how it works and inherited the logic to split frames intoblocks

Files=dir(npath);
for k=3:length(Files)
  
    FileNames=Files(k).name
[pathstr,name,ext] = fileparts(FileNames)
inputVideo = VideoReader(FileNames)

for img =1:inputVideo.NumberOfFrames
    indFrame = read(inputVideo,img)
    fname = strcat('frame',num2str(img))
   
    grayimage = rgb2gray(indFrame)


[rows, columns, numberOfColorBands] = size(grayimage);


RowSize = nres;
ColSize = nres;
%Gets the no of cell blocks - row
blockRows = floor(rows/RowSize)
%Gets the no of cell blocks - row
blockCols = floor(columns/ColSize)

%gives the row&Col contents in vector format, adding the remaining if
%row%rowsize is!=0 and col%ColSize!=0

% ones returns an array of 1's
modrow = mod(rows,RowSize);
modcol = mod(columns,ColSize);
if((modrow==0)&&(modcol==0))
blockVectorR = [blockRows * ones(1, RowSize)];
blockVectorC = [blockCols * ones(1, ColSize)];
else
blockVectorR = [blockRows * ones(1, RowSize), rem(rows, blockRows)];
blockVectorC = [blockCols * ones(1, ColSize), rem(columns, blockCols)];
end

% divides the array into smaller arrays
cellblocks = mat2cell(grayimage, blockVectorR, blockVectorC);


% Now display all the blocks.
plotIndex = 1;
%returns the no of rows as first param
numPlotsR = size(cellblocks, 1);
%returns the no of rows as second param
numPlotsC = size(cellblocks, 2);
for r = 1 : numPlotsR
	for c = 1 : numPlotsC
		%fprintf('plotindex = %d,   c=%d, r=%d\n', plotIndex, c, r);
		% Specify the location for display of the image.
		subplot(numPlotsR, numPlotsC, plotIndex);
		% Extract the numerical array out of the cell
		% just for tutorial purposes.
		grayBlock = cellblocks{r,c};
       %imhist(rgbBlock);
        filename = strcat(name,fname,'cell',int2str(r),int2str(c),'.jpg')

       h = histcounts(grayBlock,nbin);
           fid=fopen(oFile,'a');

     fprintf(fid,'%d;%d;%d%d;',k-2,img,r-1,c-1);
       dlmwrite(oFile,h,'-append');
       
           fclose(fid); 
     
           
		drawnow;
		% Increment the subplot to the next location.
		plotIndex = plotIndex + 1;
	end
end
end
end
