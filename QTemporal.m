row = 95;
column = 155;
days = 30;

N = row*column;

%%%%%%%%%%%%%%%%Start calculating QTemporal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Diagonal elements
sparseIndexX = zeros(N,1);
sparseIndexY = zeros(N,1);
sparseIndexValue = zeros(N,1);


for i=1:N
    %diagonal element
    sparseIndexX(i,1) = i;
    sparseIndexY(i,1) = i;
    sparseIndexValue(i,1) = 1;
end


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

sparseIndexValue_WholeYear(m+1:(days-1)*m,1) = sparseIndexValue_WholeYear(m+1:(days-1)*m,1) + 1;


%Upper elements
sparseIndexX_Upper = zeros(N,1);
sparseIndexY_Upper = zeros(N,1);
sparseIndexValue_Upper = zeros(N,1);


for i=1:N
    sparseIndexX_Upper(i,1)=i;
    sparseIndexY_Upper(i,1)=N+i;
    sparseIndexValue_Upper(i,1)=-1;
end

[m n] = size(sparseIndexX_Upper);

sparseIndexX_WholeYear_Upper = zeros(m*(days-1),1);
sparseIndexY_WholeYear_Upper = zeros(m*(days-1),1);
sparseIndexValue_WholeYear_Upper = zeros(m*(days-1),1);

sparseIndexX_WholeYear_Upper(1:m,1)=sparseIndexX_Upper(1:m,1);
sparseIndexY_WholeYear_Upper(1:m,1)=sparseIndexY_Upper(1:m,1);
sparseIndexValue_WholeYear_Upper(1:m,1)=sparseIndexValue_Upper(1:m,1);

for day=1:days-2
    sparseIndexX_WholeYear_Upper(day*m+1:day*m+m,1)=sparseIndexX_Upper(1:m,1)+day*N;
    sparseIndexY_WholeYear_Upper(day*m+1:day*m+m,1)=sparseIndexY_Upper(1:m,1)+day*N;
    sparseIndexValue_WholeYear_Upper(day*m+1:day*m+m,1)=-1;
end


%Lower elements
sparseIndexX_Lower = zeros(N,1);
sparseIndexY_Lower = zeros(N,1);
sparseIndexValue_Lower = zeros(N,1);


for i=1:N
    sparseIndexX_Lower(i,1)=N+i;
    sparseIndexY_Lower(i,1)=i;
    sparseIndexValue_Lower(i,1)=-1;
end

[m n] = size(sparseIndexX_Lower);

sparseIndexX_WholeYear_Lower = zeros(m*(days-1),1);
sparseIndexY_WholeYear_Lower = zeros(m*(days-1),1);
sparseIndexValue_WholeYear_Lower = zeros(m*(days-1),1);

sparseIndexX_WholeYear_Lower(1:m,1)=sparseIndexX_Lower(1:m,1);
sparseIndexY_WholeYear_Lower(1:m,1)=sparseIndexY_Lower(1:m,1);
sparseIndexValue_WholeYear_Lower(1:m,1)=sparseIndexValue_Lower(1:m,1);

for day=1:days-2
    sparseIndexX_WholeYear_Lower(day*m+1:day*m+m,1)=sparseIndexX_Lower(1:m,1)+(day*N);
    sparseIndexY_WholeYear_Lower(day*m+1:day*m+m,1)=sparseIndexY_Lower(1:m,1)+(day*N);
    sparseIndexValue_WholeYear_Lower(day*m+1:day*m+m,1)=-1;
end

diagonal_size = size(sparseIndexX_WholeYear,1);
upper_size = size(sparseIndexX_WholeYear_Upper,1);
lower_size = size(sparseIndexX_WholeYear_Lower,1);

sparseIndexX_WholeYear(diagonal_size+1:(diagonal_size+upper_size),1) = sparseIndexX_WholeYear_Upper;
sparseIndexY_WholeYear(diagonal_size+1:(diagonal_size+upper_size),1) = sparseIndexY_WholeYear_Upper;
sparseIndexValue_WholeYear(diagonal_size+1:(diagonal_size+upper_size),1) = sparseIndexValue_WholeYear_Upper;

diagonal_size = size(sparseIndexX_WholeYear,1);
sparseIndexX_WholeYear(diagonal_size+1:(diagonal_size+lower_size),1) = sparseIndexX_WholeYear_Lower;
sparseIndexY_WholeYear(diagonal_size+1:(diagonal_size+lower_size),1) = sparseIndexY_WholeYear_Lower;
sparseIndexValue_WholeYear(diagonal_size+1:(diagonal_size+lower_size),1) = sparseIndexValue_WholeYear_Lower;


%Create the temporal precision matrix
QTemporal = sparse(sparseIndexX_WholeYear', sparseIndexY_WholeYear', sparseIndexValue_WholeYear', N*days, N*days);

clear diagonal_size m n row day days N sparseIndexValue sparseIndexX sparseIndexY sparseIndexX_WholeYear sparseIndexY_WholeYear
clear sparseIndexValue_WholeYear sparseIndexX_Upper sparseIndexY_Upper sparseIndexValue_Upper sparseIndexX_WholeYear_Upper
clear sparseIndexY_WholeYear_Upper sparseIndexValue_WholeYear_Upper sparseIndexX_Lower sparseIndexY_Lower sparseIndexValue_Lower
clear sparseIndexX_WholeYear_Lower sparseIndexY_WholeYear_Lower sparseIndexValue_WholeYear_Lower
clear lower_size upper_size
clear sparseIndexValue_Lower_WholeYear sparseIndexValue_Upper_WholeYear sparseIndexX_Lower_WholeYear sparseIndexX_Upper_WholeYear
clear sparseIndexY_Lower_WholeYear sparseIndexY_Upper_WholeYear


