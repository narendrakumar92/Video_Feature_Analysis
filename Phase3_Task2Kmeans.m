% file that contains the sift/hist/motion
tic
fileID=fopen('C:\Users\sdeep\Downloads\Phase3\file_d_pca.sift');
d = 60;
%cellsFromFile = textscan(fileID,['{<%f;%f;%f;%f;%f;>[',repmat('%f',1,80),']}'], 'delimiter',',');
cellsFromFile =textscan(fileID,['{<',repmat('%f',1, 5),'>,[',repmat('%f', 1, d),']}'],'delimiter', ',');
matrixFromFile = cell2mat(cellsFromFile);
fclose(fileID);
% k most similar frame sequence
 k= 2;
% get unique video files from the sift file
max_vid=unique( matrixFromFile(:,1) );
% get max count of videos
total_videos=max(matrixFromFile(:,1));
outputFileName='C:\Users\sdeep\Downloads\Phase3\out_file_60_10.spc';
 fileIdToWrite = fopen(outputFileName,'w+');
% to get the unique video,frame from the matrix
unique_Video_Frame_Matrix=matrixFromFile;
unique_Video_Frame_Matrix(:,3:end)=[];
unique_Video_Frame_Matrix=unique(unique_Video_Frame_Matrix,'rows');
[ total_rows,total_columns ] = size(unique_Video_Frame_Matrix);
similar_rows = total_rows * total_rows;
similarity_percentage_matrix=zeros(similar_rows,5);
m=1;
videoFrame3D=zeros(1500,d,total_rows);
videoFrameDim=zeros(total_rows,2);
for t = 1 : total_rows
    video_t= unique_Video_Frame_Matrix(t,1);
    frame_t = unique_Video_Frame_Matrix(t,2);
    video_t_frame_matrix=matrixFromFile(matrixFromFile(:,1) == video_t ...
        & matrixFromFile(:,2) == frame_t ,:);
    video_t_frame_matrix(:,1:5)=[];
    dim = size(video_t_frame_matrix);
    %videoFrame3D(1:dim(1),1:dim(2),t)=video_t_frame_matrix;
    %videoFrameDim(t,:)= [dim(1),dim(2)];
    if ( dim(1) < 100 )
        minClusters = dim(1);
        %         addRows = 50 - minClusters;
        [centers, assignments] = vl_kmeans(video_t_frame_matrix', minClusters);
        %         rowVect = centers(1,:);
        %         addRowsToCenters = rowVect(ones(addRows,1),:);
        %         centers = [ centers ; addRowsToCenters];
        %         numClusters= 50;
        videoFrame3D(1:dim(2),1:minClusters,t)=centers;
        videoFrameDim(t,:)= [dim(2),minClusters];
    else
        numClusters = 100;
        [centers, assignments] = vl_kmeans(video_t_frame_matrix', numClusters);
        videoFrame3D(1:dim(2),1:numClusters,t)=centers;
        videoFrameDim(t,:)= [dim(2),numClusters];
    end;
    
    if( t ==1 )
        T = arrayfun(@(t)vl_kdtreebuild(centers),1:total_rows, 'UniformOutput',0);
        kdtree = horzcat(T{:});

        clear T
    else
        kdtree(t)=vl_kdtreebuild(centers);
    end
end;
toc
tic
for i = 1 : total_rows
    video_i = unique_Video_Frame_Matrix(i,1);
    frame_i = unique_Video_Frame_Matrix(i,2);
    video_i_frame_matrix = videoFrame3D(1:videoFrameDim(i,1),1:videoFrameDim(i,2),i);
    for j = 1 : total_rows
        video_j = unique_Video_Frame_Matrix(j,1);
        frame_j = unique_Video_Frame_Matrix(j,2);
        if( video_i == video_j )
            continue;
        end;
        video_j_frame_matrix=videoFrame3D(1:videoFrameDim(j,1),1:videoFrameDim(j,2),j);
        testTree = kdtree(j);
        [index, distance]=vl_kdtreequery(kdtree(j),video_j_frame_matrix, video_i_frame_matrix,'NumNeighbors', 2) ;
        % ,'MaxComparisons', 15
        distance_ratio = bsxfun(@rdivide, distance(1,:), distance(2,:));
        threshold_distance = distance_ratio < 0.7;
        distance_ratio = distance_ratio(threshold_distance);
        similarityPercentBetweenFrames = (size(distance_ratio,2)/ size(distance,2))* 100;
        similarity_percentage_matrix(m,:) = [video_i,frame_i,video_j,frame_j,similarityPercentBetweenFrames];
        m=m+1;
    end;
end;
toc
for t = 1 :total_rows
    video_i = unique_Video_Frame_Matrix(t,1);
    frame_i = unique_Video_Frame_Matrix(t,2);
    tempMat=similarity_percentage_matrix(similarity_percentage_matrix(:,1) == video_i & similarity_percentage_matrix(:,2) == frame_i,:);
    A=sortrows(tempMat,-5);
    for v = 1 : k
        fprintf(fileIdToWrite,'{<%d,%d>,<%d,%d>,%f}\r\n',A(v,1),A(v,2),A(v,3),A(v,4),A(v,5));
    end;
end;