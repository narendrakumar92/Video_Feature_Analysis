prompt={'Enter value for video (i)',...
    'Enter value for frame (j)',...
    'Enter value for x1',...
    'Enter value for y1',...
    'Enter value for x2',...
    'Enter value for y2',...
    'Enter value for k',...
    'Enter value for dimension',...
    'Enter the absolute video directory'
    };
dlg_title='Input for Task 6';
num_lines=1;
default={'52','10','210','0','340','400','5','60','C:\Users\sdeep\Downloads\Demo Videos\'};
input=inputdlg(prompt,dlg_title,num_lines,default);
i= str2num(input{1});
j= str2num(input{2});
x1=str2num(input{3});
y1=str2num(input{4});
x2=str2num(input{5});
y2=str2num(input{6});
n = str2num(input{7});
d = str2num(input{8});
dirPath = input{9};
%output_file_path = 'D:\ASU\MWDB\Project-3\Output\out_file_lsh.t6';
% out_file_id = fopen(output_file_path, 'w');
%task -5
 t5_file_id = fopen('C:\Users\sdeep\Downloads\filename_d_60L3K5.spc');
 cell_file_t5 = textscan(t5_file_id,'{%f,%f,<%f;%f;%f;%f;%f;>}');
 matrix_from_file_t5 = cell2mat(cell_file_t5);
% 
% %task -2 
 t2_file_id=fopen('C:\Users\sdeep\Downloads\Phase3\file_d_pca.sift');
 d = 60;
 cell_file_t2 =textscan(t2_file_id,['{<',repmat('%f',1, 5),'>,[',repmat('%f', 1, d),']}'],'delimiter', ',');
 fclose(t2_file_id);
 matrix_from_file_t2 = cell2mat(cell_file_t2);


% i= 48;
% j= 18;
% x1=0;
% y1=120;
% x2=200;
% y2=350;
% n = 5;        
            
queryVideo=matrix_from_file_t5(matrix_from_file_t5(:,3) == i & matrix_from_file_t5(:,4) == j ,:);
maxLayers=max(queryVideo(:,1));
%finalDesc=[];
similar_video_frames= zeros(1000,2);
svf = 1;

total_descriptors=0;
for layerInd = 1 : maxLayers
    finalDesc=[];
    layerMatrix = matrix_from_file_t5(matrix_from_file_t5(:,1) == layerInd , : );
    rectDesc=queryVideo( (queryVideo(:,1) == layerInd) & ( queryVideo(:,6) >= x1 & queryVideo(:,6) <= x2) & ...
        ( queryVideo(:,7) >= y1 & queryVideo(:,7) <= y2 ) ,:);

    if isempty(rectDesc)
        fprintf('Rectangle empty with no descriptors');
        exit;
    end;
    
    [ maxdesc,~] = size(rectDesc);
    indxMatrix = rectDesc(:,2);
    indxValues = unique(indxMatrix);
    indxInstances = histc(indxMatrix(:),indxValues);
    indxMatrixMax = [ indxValues indxInstances ];
    indxMatrixMax = sortrows(indxMatrixMax,-2);
    [ indxCount , ~ ] = size(indxMatrixMax);

for index = 1 : indxCount
        matchDesc=layerMatrix( layerMatrix(:,2) == indxMatrixMax(index,1) & layerMatrix(:,3) ~= i ,:);
        finalDesc = [finalDesc ; matchDesc]; 
end;

[ descriptors , ~ ] = size(finalDesc);
 total_descriptors = total_descriptors + descriptors;
% per layer desc found, find disticnt (v,f) that are present in all buckets
indxVideoFrame = finalDesc;
indxVideoFrame(:,[1,5,6,7])=[];
indxVideoFrame = sortrows(indxVideoFrame,[2,3]);
indxVideoFrame = unique(indxVideoFrame,'rows');

% get unique video ,frame from the above matrix
unique_video_frame_matrix = indxVideoFrame;
unique_video_frame_matrix(:,1) = [];
unique_video_frame_matrix = unique(unique_video_frame_matrix,'rows');
[ unrows, ~ ] = size(unique_video_frame_matrix);
% check for each unique video frame , all the descriptors are present
for uvf = 1 : unrows
    video = unique_video_frame_matrix(uvf,1);
    frame = unique_video_frame_matrix(uvf,2);
    tempMatrix = indxVideoFrame( indxVideoFrame(:,2) == video  & ...
        indxVideoFrame(:,3) == frame, :);
    tempMatrix = unique(tempMatrix,'rows') ; 
    [ videoqualifier, ~ ] = size(tempMatrix);
    
    if videoqualifier == indxCount
        % put it in a matrix
        similar_video_frames(svf,:) = [video, frame ];
        svf = svf + 1;
    end;
end;
end;

% get the descriptors for query frame
matrixForRect = rectDesc;
descForRect = [];
[ nrows , ~ ] = size(matrixForRect);

for x = 1 : nrows
tempMatrix = matrix_from_file_t2( (matrix_from_file_t2(:,1) == matrixForRect(x,3)) & (matrix_from_file_t2(:,2) == matrixForRect(x,4)) ...
    & (matrix_from_file_t2(:,3) == matrixForRect(x,5)) &  (matrix_from_file_t2(:,4) == matrixForRect(x,6)) ...
    & (matrix_from_file_t2(:,5) == matrixForRect(x,7)),:);
descForRect = [ descForRect ; tempMatrix];
end;
descForRect(:,1:5)=[];
% get descriptors for frame matrix

descForPotFrame = [];
similar_video_frames = similar_video_frames(any(similar_video_frames,2),:);
similar_video_frames = unique(similar_video_frames,'rows');
[ nrows , ~ ] = size(similar_video_frames);
similarity_percentage_matrix = zeros(nrows,3);
m =1;
unique_descriptors = 0 ;
total_bytes = 0;
for x = 1 : nrows
    tempMatrix = matrix_from_file_t2( (matrix_from_file_t2(:,1) == similar_video_frames(x,1)) ...
        & (matrix_from_file_t2(:,2) == similar_video_frames(x,2)),:);
    % compare the two frames
    video = tempMatrix(1,1);
    frame = tempMatrix(1,2);
    tempMatrix(:,1:5)=[];
    [temp_unique_descriptors,~] = size(tempMatrix);
    unique_descriptors = unique_descriptors+ temp_unique_descriptors;
    temp_bytes = whos('tempMatrix');
    total_bytes = total_bytes + [temp_bytes.bytes];
    kdtree=vl_kdtreebuild(descForRect');
    [index, distance]=vl_kdtreequery(kdtree,descForRect', tempMatrix','NumNeighbors', 2) ;
        distance_ratio = bsxfun(@rdivide, distance(1,:), distance(2,:));
        threshold_distance = distance_ratio < 0.7;
        distance_ratio = distance_ratio(threshold_distance);
        similarityPercentBetweenFrames = (size(distance_ratio,2)/ size(distance,2))* 100;
        similarity_percentage_matrix(m,:) = [video,frame,similarityPercentBetweenFrames]; 
        m = m +1;
end;

sortedRankMatrix = sortrows(similarity_percentage_matrix, -3 );

%dirPath = 'C:\Users\sdeep\Downloads\Demo Videos\';
dirFiles = strcat(dirPath,'\*.mp4');
listVideoFiles=dir(dirFiles);

for q = 1 : length(listVideoFiles)
    videoFileName=listVideoFiles(q).name;
    videoFrames= VideoReader(strcat(dirPath,videoFileName));
    
    for r = 1 : n
        checkVideo = sortedRankMatrix(r,1);
        checkFrame = sortedRankMatrix(r,2);
        if( q == checkVideo )
            fprintf('result=> %s\n',videoFileName);
            imageName = strcat(dirPath,'task6_result_',num2str(checkVideo),'_',num2str(checkFrame),'.jpg');
            myFrame = read(videoFrames,checkFrame);
            imwrite(myFrame, imageName, 'jpg');
        end;
    end;
    
    if( q == i )
        fprintf('query => %s\n',videoFileName);
        imageName = strcat(dirPath,'task6_query',num2str(i),'_',num2str(j),'.jpg');
        myFrame = read(videoFrames,j);
        imwrite(myFrame, imageName, 'jpg');
    end;
end;

fprintf('Total number of descriptors considered (overall) - %d\n',total_descriptors);
fprintf('Total number of unique descriptors considered - %d\n',unique_descriptors);
fprintf('Total number of bytes - %d\n',total_bytes);