%%%%%%%%%%%%%%%%%%%%%%%%%% Generating synthetic data%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 1000;

x1 = zeros(N,1);
x2 = zeros(N,1);
y = zeros(N,1);
b=zeros(N,1);

alpha1 = 5;
alpha2 = 1;


for i=1:N
    x1(i,1) = randn;
    x2(i,1) = randn;  
end

indicator_x1 = (x1 ~= 0);
indicator_x2 = (x2 ~= 0);

Q1 = alpha1*spdiags(indicator_x1, 0, N, N) + alpha2*spdiags(indicator_x2, 0, N, N);

Q = 2*Q1;

for i=1:N
    b(i,1) = 2 * (alpha1*x1(i,1) + alpha2*x2(i,1));
end

mui = Q\b;

sigma = inv(Q);


for i=1:N
    y(i,1) = mui(i,1) + sqrt(sigma(i,i))*randn;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Batch gradient descent
alpha1=1;
alpha2=1;

indicator_x1 = (x1 ~= 0);
indicator_x2 = (x2 ~= 0);

absolon = 0.000001;

iterations = 0;

tic;

alpha1s = zeros(100,1);
alpha2s = zeros(100,1);
fs = zeros(100,1);

while true   
    b = 2*(alpha1*x1 + alpha2*x2);
    
    Q1 = alpha1*spdiags(indicator_x1, 0, N, N) + alpha2*spdiags(indicator_x2, 0, N, N);
    Q = 2*Q1;
    
    mui = Q\b;
    
    sigma_inv = Q;
    
    gradient_alpha1 = -0.5 * (y-mui)'*2*spdiags(indicator_x1, 0, N, N)*(y-mui) + ((2*x1)'-mui'*2*spdiags(indicator_x1, 0, N, N))*(y-mui) + ...
        0.5*trace(sigma_inv \ (2*spdiags(indicator_x1, 0, N, N)));
    
    gradient_alpha2 = -0.5 * (y-mui)'*2*spdiags(indicator_x2, 0, N, N)*(y-mui) + ((2*x2)'-mui'*2*spdiags(indicator_x2, 0, N, N))*(y-mui) + ...
        0.5*trace(sigma_inv \ (2*spdiags(indicator_x2, 0, N, N)));
    
    F = -0.5*(y-mui)'*sigma_inv*(y-mui) + 0.5*(2 * sum(log(diag(chol(sigma_inv)))));
    
    alpha1_new = exp(log(alpha1) + learning_rate * alpha1 * gradient_alpha1);
    alpha2_new = exp(log(alpha2) + learning_rate * alpha2 * gradient_alpha2);
    
    
    delta_alpha1 = abs(alpha1_new - alpha1);
    delta_alpha2 = abs(alpha2_new - alpha2);
    
    [F delta_alpha1 delta_alpha2 alpha1 alpha2]
    
    if delta_alpha1 < absolon && delta_alpha2 < absolon
        break;
    end
    
    alpha1 = alpha1_new;
    alpha2 = alpha2_new;
    
    iterations = iterations + 1;
    
    %alpha1s(iterations,1) = alpha1;
    %alpha2s(iterations,1) = alpha2;
    %fs(iterations,1) = F;
       
end

toc;


%test
total = 0;
for i=1:N
    total = total + (-0.5* (y(i,1)-mui(i,1)) *2 * (y(i,1)-mui(i,1)) + (2*x1(i,1)-mui(i,1)*2)* (y(i,1)-mui(i,1)) + 0.5* (sigma_inv(i,i)\2));
end

%Stochastic gradient descent

alpha1=1;
alpha2=1;

absolon = 0.0001;
iterations = 1;

block_size = 1;

tic;

alpha1s = zeros(100,1);
alpha2s = zeros(100,1);
fs = zeros(100,1);


while true  
    learning_rate = 1/sqrt(iterations);
    index = randi([1,N-20]);

    start = index;
    stop = index + block_size - 1;
    
    indicator_x1 = (x1(start:stop) ~= 0);
    indicator_x2 = (x2(start:stop) ~= 0);
    
    b = 2*(alpha1*x1(start:stop) + alpha2*x2(start:stop));
    
    Q1 = alpha1*spdiags(indicator_x1, 0, block_size, block_size) + alpha2*spdiags(indicator_x2, 0, block_size, block_size);
    Q = 2*Q1;
    
    mui = Q\b;
    
    sigma_inv = Q;
    
    gradient_alpha1 = -0.5 * (y(start:stop)-mui)'*2*spdiags(indicator_x1, 0, block_size, block_size)*(y(start:stop)-mui) + ((2*x1(start:stop))'-mui'*2*spdiags(indicator_x1, 0, block_size, block_size))*(y(start:stop)-mui) + ...
        0.5*trace(sigma_inv \ (2*spdiags(indicator_x1, 0, block_size, block_size)));
    
    gradient_alpha2 = -0.5 * (y(start:stop)-mui)'*2*spdiags(indicator_x2, 0, block_size, block_size)*(y(start:stop)-mui) + ((2*x2(start:stop))'-mui'*2*spdiags(indicator_x2, 0, block_size, block_size))*(y(start:stop)-mui) + ...
        0.5*trace(sigma_inv \ (2*spdiags(indicator_x2, 0, block_size, block_size)));
    
    %Actual objective function
    b_actual = 2*(alpha1*x1 + alpha2*x2);
    indicator_x1_actual = (x1 ~= 0);
    indicator_x2_actual = (x2 ~= 0);
    Q1_actual = alpha1*spdiags(indicator_x1_actual, 0, N, N) + alpha2*spdiags(indicator_x2_actual, 0, N, N);
    Q_actual = 2*Q1_actual;
    sigma_inv_actual = Q_actual;
    mui_actual = Q_actual\b_actual;
    
    F = -0.5*(y-mui_actual)'*sigma_inv_actual*(y-mui_actual) + 0.5*(2 * sum(log(diag(chol(sigma_inv_actual)))));
    
    alpha1_new = exp(log(alpha1) + learning_rate * alpha1 * gradient_alpha1);
    alpha2_new = exp(log(alpha2) + learning_rate * alpha2 * gradient_alpha2);
    
    
    delta_alpha1 = abs(alpha1_new - alpha1);
    delta_alpha2 = abs(alpha2_new - alpha2);
    
    [delta_alpha1 delta_alpha2 alpha1 alpha2]
    
    if delta_alpha1 < absolon && delta_alpha2 < absolon
        break;
    end
    
    %alpha1s(iterations,1) = alpha1;
    %alpha2s(iterations,1) = alpha2;
    %fs(iterations,1) = F;
    
    
    alpha1 = alpha1_new;
    alpha2 = alpha2_new;
    
    iterations = iterations + 1;
       
end

toc;
