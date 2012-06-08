function F = calculate_weight(w)
    %The parameters of the exponential variogram
    global A lambda
    
    row = size(w,1);
   
    F=zeros(row+1,1);
    for i=1:row-1
        equation = 0;
        for j=1:row-1
            equation = equation +  w(j)*A*exp(lambda * distance_neighbors(i,j));
        end
        equation = equation + w(row) - A*exp(lambda*distance_interp(i,1));
        F(i) = equation;
    end
    
    sum_equation = 0;
    for i=1:row-1
        sum_equation = sum_equation + w(i);
    end
    
    F(row)=sum_equation-1;
    