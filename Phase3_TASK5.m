
prompt={'Enter the Dimension:',...
    'Enter the K value (2^k buckets)',...
    'Enter the inputfile path from task 1',...
    'Enter the output directory to visualize',...
    'Enter the L value (No of Layers)',...
    };
dlg_title='Input for Task 5 (LSH)';
num_lines=1;
default={'10','5','C:\Users\naren\Desktop\SUBMIT P3\Task 1\D10\file_d_pca_d10.sift','C:\Users\naren\Desktop\SUBMIT P3\Task 5 hyperplane\out_task5.lsh','3'}; %need to change if someother laptpo
input=inputdlg(prompt,dlg_title,num_lines,default);
Kvalue=str2num(input{2});
Lvalue=str2num(input{5});
inputfile=input{3};
outputfile=input{4};

Dimen = str2num(input{1});


fileID=fopen(inputfile);
cellsFromFile = textscan(fileID,['{<', repmat('%f',1,5),'>',',[',repmat('%f',1,Dimen),']}'], 'delimiter',',');
cellsFromFileRaw = cellsFromFile;

dimension =Dimen;
C = [1 2 3]
cellsFromFile(:,C) = []
Rawdata = cell2mat(cellsFromFileRaw);
Predata = Rawdata(:,[1:5]);
Postdata = Rawdata(:,[6:dimension+5]);

Layercount = Lvalue;
K = Kvalue;
Buckets = power(2,K);



%for 3 hyperplanes in Layer 1

    a=-1;
    b=1;
   

%a = HyperPlane{1};

[row col] = size(Postdata);

Nbit = zeros(row,K+1);


for LayerIter= 1:Layercount
    Nbit(1:row,1) = 0; 
Layernum(1:row,1) = LayerIter;
%for every hyperplane calculate 1's and 0's
for j = 1 : K
     HyperPlane{j} = a + (b-a).*rand(1,dimension);
    for i = 1 : row
        newmat = Postdata(i,:);
        hyperp = HyperPlane{j};
        ans1 =  dot(newmat,hyperp);
        if ans1 >= 0
            binaryval = 1;
            Nbit(i,1) = Nbit(i,1)+ power(2,K-j);
        else
            binaryval = 0;
        end
        
        Nbit(i,j+1) = binaryval;

    end
end
%end
Bucketnum = Nbit(:,1);

FinalMat = [Layernum Bucketnum Predata]; %this holds the answer

[rowPostdata colPostdata] = size(FinalMat);
fid=fopen(outputfile,'a');
for i = 1:rowPostdata
   tempmat1 = FinalMat(i,[1:2]);
   tempmat2 = FinalMat(i,[3:7]);
    fprintf(fid,'{');
 
    fprintf(fid,[repmat('%d,', 1, size(tempmat1, 2)) ], tempmat1');
    fprintf(fid,'<');
    fprintf(fid,[repmat('%d;', 1, size(tempmat2, 2)) ], tempmat2');
    fprintf(fid,'>');
    fprintf(fid,'}\n');
 
 end;
fclose(fid);

end;
Layer = [Predata Nbit];

