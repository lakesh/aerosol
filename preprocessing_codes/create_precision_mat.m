rows=20;
columns=20;

%Random initialization
data=zeros(1000,3);
index=1;
value=-1;

%3x3 neighborhood
%For each element the neighbors are accessible within 1 hop so neighbors=1
neighbors=1;


for i=1:rows
    for j=1:columns
        
        for k=1:neighbors
            %same row right
            if j+k <= columns
                data(index,1) = (i-1)*columns+j;
                data(index,2) = ((i-1)*columns) + (j+k);
                data(index,3) = value;
                index=index+1;
            end

            %same row left
            if j-k >= 1;
                data(index,1) = (i-1)*columns+j;
                data(index,2) = ((i-1)*columns) + (j-k);
                data(index,3) = value;
                index=index+1;
            end
        end
        
        
        %row below -> bottom left right
        for k=i+1:i+neighbors
            if k <= rows
                %bottom
                data(index,1) = (i-1)*columns+j;
                data(index,2) = (k-1)*columns + j;
                data(index,3) = value;
                index=index+1;
                
                for l=1:neighbors
                    %right
                    if j+l <= columns
                        data(index,1) = (i-1)*columns+j;
                        data(index,2) = ((k-1)*columns) + (j+1);
                        data(index,3) = value;
                        index=index+1;
                    end

                    %left
                    if j-l >= 1;
                        data(index,1) = (i-1)*columns+j;
                        data(index,2) = ((k-1)*columns)+(j-1);
                        data(index,3) = value;
                        index=index+1;
                    end
                end
                
            end
            
            
        end
            
        
        
        
        %row above top left right
        for k=i-1:i-neighbors
            if k >= 1
                %top
                data(index,1) = (i-1)*columns+j;
                data(index,2) = ((k-1)*columns) +j;
                data(index,3) = value;
                index=index+1;
                
                for l=1:neighbors
                    %right
                    if j+l <= columns
                        data(index,1) = (i-1)*columns+j;
                        data(index,2) = ((k-1)*columns) + (j+1);
                        data(index,3) = value;
                        index=index+1;
                    end

                    %left
                    if j-k >= 1;
                        data(index,1) = (i-1)*columns+j;
                        data(index,2) = ((k-1)*columns) + (j-1);
                        data(index,3) = value;
                        index=index+1;
                    end
                end
            end
        end  
    end
end

%Get the values for the diagonal elements(which is equal to the number of
%neighbors or absolute sum of the nondiagonal elements of the corresponding
%row)

diagonal_values = zeros(rows*columns,3);
for i=1:rows*columns
    pointer=find(data(:,1) == i);
    diag_value=abs(sum(data(pointer,3)));
    diagonal_values(i,1) = i;
    diagonal_values(i,2) = i;
    diagonal_values(i,3) = diag_value;
end

data(index:index+rows*columns-1,:)=diagonal_values(:,:);


Q = sparse(data(:,1), data(:,2), data(:,3), rows*columns, rows*columns);    

