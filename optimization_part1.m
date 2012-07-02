global len learning_rate alpha3 row column days numberOfDays N QSpatial file_path file_prefix precision_matrix_path
learning_rate = 0.0001;

alpha3 = 0.001;

row = 95;
column = 155;
days = 30;
numberOfDays = 30;

N = row*column;

file_path = '/Users/lakesh/Aerosol/synthetic1/';
file_prefix = 'collocated_MISR_MODIS_AERONET_NEW_';

precision_matrix_path = '/Users/lakesh/Aerosol/synthetic1/QSpatial.mat';


% Matrix to hold the index for each data point 
linearMatrix = zeros(row*column*numberOfDays,4);
index = 1;

for day=1:numberOfDays
    for i=1:row
        for j=1:column
            linearMatrix(index,1) = i;
            linearMatrix(index,2) = j;
            linearMatrix(index,3) = day;
            linearMatrix(index,4) = index;
            index = index+1;
        end
    end
end
%%%%%%%%%%%%%%%%Start calculating QSpatial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%We calculate the precision matrix for a single day only
%Then replicate the same matrix through out the year

%Save the row, column and the values of those elements who have non zero
%values which can be used later for sparse matrix creation
sparseIndexX = zeros(N,1);
sparseIndexY = zeros(N,1);
sparseIndexValue = zeros(N,1);

row = 191;
column = 311;

index = 1;
for j=1:N
    x = linearMatrix(j,1);
    y = linearMatrix(j,2);
    for k=1:N
        x1 = linearMatrix(k,1);
        y1 = linearMatrix(k,2);

        if(j == k)
            %diagonal element
            sparseIndexX(index,1) = j;
            sparseIndexY(index,1) = k;


            % For the four corner elements number of neighbours = 2
            if j == 1 || j == N || (x == 1 && y == column) || (x == row && y == 1)
                sparseIndexValue(index,1) = 2;
            elseif x >=2 && y >= 2 && x < row && y < column
                % For the elements in the middle number of neighbours = 4
                sparseIndexValue(index,1) = 4;
            else
                % For the elements at the edge but not the corner
                % number of neighbours = 3
                sparseIndexValue(index,1) = 3;
            end
            index = index + 1;
        else
            %if the elements are adjacent 
            if (abs(x-x1) == 1 && abs(y-y1) == 0) || (abs(x-x1) == 0 && abs(y-y1) == 1)
                sparseIndexX(index,1) = j;
                sparseIndexY(index,1) = k;
                sparseIndexValue(index,1) = -1;
                index = index + 1;
            end
        end
    end
end

clear linearMatrix

[m n] = size(sparseIndexX);

sparseIndexX_WholeYear = zeros(m*days,1);
sparseIndexY_WholeYear = zeros(m*days,1);
sparseIndexValue_WholeYear = zeros(m*days,1);

sparseIndexX_WholeYear(1:m,1)=sparseIndexX(1:m,1);
sparseIndexY_WholeYear(1:m,1)=sparseIndexY(1:m,1);
sparseIndexValue_WholeYear(1:m,1)=sparseIndexValue(1:m,1);

for day=1:days-1
    sparseIndexX_WholeYear(day*m+1:day*m+m,1)=sparseIndexX(1:m,1)+day*N;
    sparseIndexY_WholeYear(day*m+1:day*m+m,1)=sparseIndexY(1:m,1)+day*N;
    sparseIndexValue_WholeYear(day*m+1:day*m+m,1)=sparseIndexValue(1:m,1);
end

clear sparseIndexX sparseIndexY sparseIndexValue

tic;
QSpatial = sparse(sparseIndexX_WholeYear', sparseIndexY_WholeYear', sparseIndexValue_WholeYear', N*days, N*days);
toc;

clear sparseIndexValue sparseIndexValue_WholeYear sparseIndexX sparseIndexX_WholeYear sparseIndexY sparseIndexY_WholeYear
%%%%%%%%%%%%%%%% End of calculating QSpatial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

len = days*N;
