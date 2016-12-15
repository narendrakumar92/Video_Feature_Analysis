
 prompt={'Enter the Dimension:',...
     };
 dlg_title='Input for Task 1';
num_lines=1;
default={'10'}; %need to change if someother laptpo
input=inputdlg(prompt,dlg_title,num_lines,default);
Dimen=str2num(input{1});
        %SIFT ENTIRE starts
        fileID=fopen('C:\Naren\Grad courses\MWD CSE515\Projects\Project 3\SIFT\out_file_p3.sift');
        cellsFromFile = textscan(fileID,['<%f;%f;%f;[',repmat('%f',1,2),repmat('%f',1,130),']>'], 'delimiter',',');
        cellsFromFileRaw = cellsFromFile;
        Rawdata = cell2mat(cellsFromFileRaw); 
        Predata = Rawdata(:,[1:5]);
        COL = [1 2 3 4 5];
        cellsFromFile(:,COL) = [];
        X = cell2mat(cellsFromFile);
        ODimension = [1:130];
        ODimension = transpose(ODimension);

        
        znormalized = zscore(X);
        
        [coeff,score] = pca(znormalized);
        
        
        
        
        
        no_dims = Dimen;
        M = coeff(:,[1:no_dims]) %Score as per project
        projection = score(:,[1:no_dims]); %k dimensional feature vector
        Postdata = [Predata,projection];
        [rowPostdata, colPostdata] = size(Postdata);

         fid=fopen('C:\Naren\Grad courses\MWD CSE515\Projects\Project 3\D60\file_d_pca.sift','a');
         fidbssift=fopen('C:\Naren\Grad courses\MWD CSE515\Projects\Project 3\D60\file_d_pca_score.sift','a');
         %sift output
        for i = 1:rowPostdata
           tempmat1 = Postdata(i,[1:5]);
           tempmat2 = Postdata(i,[6:(no_dims+5)]);
           fprintf(fid,'{<');

           fprintf(fid,[repmat('%d,', 1, size(tempmat1, 2)) ], tempmat1');
           fprintf(fid,'>,[');
           fprintf(fid,[repmat('%f,', 1, size(tempmat2, 2)) ], tempmat2');
           fprintf(fid,']');
           fprintf(fid,'}\n');

        end 




        [rows, columns] = size(M);
        FINALVAL =  abs(M); %from stack overflow, the coeff should be in positive, so abs is used
        for xnewdimen = 1:columns


            b = FINALVAL(:,xnewdimen);
            c= [ODimension, b];

          val.OLD = ODimension;
          val.SCORE = b;

          [tmp ind]=sort(val.SCORE,'descend') %tmp and ind has proper values

          [rowindexcountsift, colindexcountsift] = size(tmp);
          for rindex = 1:rowindexcountsift

            fprintf(fidbssift,'<%d;%d;%d>\n',xnewdimen,ind(rindex,1),tmp(rindex,1));

          end

          ans = [ind,tmp] %This has floats

        end

        fclose(fidbssift); 
        fclose(fid);

        %Sift ends here
    
 
 


 
    