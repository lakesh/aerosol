%%%%%%%%%%%%%%%%%%%%%%%%%% Generating synthetic data%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


N = 5374625;

for i=2004:2007


    %x1 = zeros(N,1);
    %x2 = zeros(N,1);
    y = zeros(N,1);
    b=zeros(N,1);

    alpha1 = 5;
    alpha2 = 1;


    x1 = randn(1,N)';
    x2 = randn(1,N)';
    %for i=1:N
    %    x1(i,1) = randn;
    %    x2(i,1) = randn;  
    %end

    indicator_x1 = (x1 ~= 0);
    indicator_x2 = (x2 ~= 0);

    Q1 = alpha1*spdiags(indicator_x1, 0, N, N) + alpha2*spdiags(indicator_x2, 0, N, N);

    Q = 2*Q1;

    b = 2 * (alpha1*x1 + alpha2*x2);


    %for i=1:N
    %    b(i,1) = 2 * (alpha1*x1(i,1) + alpha2*x2(i,1));
    %end

    mui = Q\b;

    sigma = inv(Q);


    %for i=1:N
    %    y(i,1) = mui(i,1) + sqrt(sigma(i,i))*randn;
    %end
    y = mui + sqrt(diag(sigma))*randn;
    
    
    load(['collocated_misr_modis_aeronet_' num2str(i) '.mat']);
    colloc_data = collocated_misr_modis_aeronet;
    misr = colloc_data(:,1);
    index=find(misr == 0);
    x1(index) = 0;
    modis = colloc_data(:,2);
    index = find(modis==0);
    x2(index) = 0;
    aeronet = colloc_data(:,3);
    index = find(aeronet == 0);
    y(index) = 0;
    
    colloc_data(:,1) = x1;
    colloc_data(:,2) = x2;
    colloc_data(:,3) = y;
    
    save(['colloc_data_' num2str(i) '.mat'],'colloc_data');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Batch gradient descent
alpha1=1;
alpha2=1;
alpha3 = 0.001;

indicator_x1 = (x1 ~= 0);
indicator_x2 = (x2 ~= 0);
indicator_x3 = (x2 ~= -9999);


absolon = 0.000001;

iterations = 0;

tic;

alpha1s = zeros(100,1);
alpha2s = zeros(100,1);
fs = zeros(100,1);

while true   
    b = 2*(alpha1*x1 + alpha2*x2);
    
    Q1 = alpha1*spdiags(indicator_x1, 0, N, N) + alpha2*spdiags(indicator_x2, 0, N, N) + alpha3*spdiags(indicator_x3, 0, N, N);
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
alpha3 = 0.0001;

absolon = 0.00000001;
iterations = 1;

block_size = 1;

tic;

alpha1s = zeros(100,1);
alpha2s = zeros(100,1);
fs = zeros(100,1);

days = 365;
N=95*155;

for j=1:1000
    year = 2004;
    
    load(['colloc_data_masked_' num2str(year) '.mat']);
    
    %learning_rate = 1/sqrt(iterations + 100);
    index = randi([1,days]);

    start = (index-1)*N + 1;
    stop = start + N - 1;
    
    x1 = colloc_data(start:stop,1);
    x2 = colloc_data(start:stop,2);
    y = colloc_data(start:stop,3);
    
    b = 2*(alpha1*x1 + alpha2*x2);
    
    indicator_x1 = (x1 ~= 0);
    indicator_x2 = (x2 ~= 0);
    indicator_x3 = (x2 ~= -9999);
    
    labelled = find(y ~= 0);
    unlabelled = find(y==0);
    
    
    
    Q1 = alpha1*spdiags(indicator_x1, 0, N, N) + alpha2*spdiags(indicator_x2, 0, N, N) + alpha3*spdiags(indicator_x3, 0, N, N);
    Q = 2*Q1;
  
    
    sigma_inv = Q;
    
    Q_LL = sigma_inv(labelled,:);
    Q_LL = Q_LL(:,labelled);
    Q_UU = sigma_inv(unlabelled, :);
    Q_UU = Q_UU(:,unlabelled);
    Q_LU = sigma_inv(labelled, :);
    Q_LU = Q_LU(:, unlabelled);
    Q_UL = sigma_inv(unlabelled,:);
    Q_UL = Q_UL(:, labelled);
    
    QLU_inv_QUU = Q_LU / Q_UU;
    
    sigma_inv_star = Q_LL - (QLU_inv_QUU) * Q_UL;
    mui_star = sigma_inv_star\b(labelled);
    
    truth_aeronet = y(labelled);
    forecast_x1 = x1(labelled);
    forecast_x2 = x2(labelled);

    alpha1_sigma_inv = 2 * spdiags(indicator_x1, 0, N, N);
    alpha1_sigma_inv_LL = alpha1_sigma_inv(labelled,:);
    alpha1_sigma_inv_LL = alpha1_sigma_inv_LL(:,labelled);
    alpha1_sigma_inv_LU = alpha1_sigma_inv(labelled,:);
    alpha1_sigma_inv_LU = alpha1_sigma_inv_LU(:,unlabelled);
    alpha1_sigma_inv_UL = alpha1_sigma_inv(unlabelled,:);
    alpha1_sigma_inv_UL = alpha1_sigma_inv_UL(:,labelled);
    alpha1_sigma_inv_UU = alpha1_sigma_inv(unlabelled,:);
    alpha1_sigma_inv_UU = alpha1_sigma_inv_UU(:,unlabelled);

    alpha2_sigma_inv = 2 * spdiags(indicator_x2, 0, N, N);
    alpha2_sigma_inv_LL = alpha2_sigma_inv(labelled,:);
    alpha2_sigma_inv_LL = alpha2_sigma_inv_LL(:,labelled);
    alpha2_sigma_inv_LU = alpha2_sigma_inv(labelled,:);
    alpha2_sigma_inv_LU = alpha2_sigma_inv_LU(:,unlabelled);
    alpha2_sigma_inv_UL = alpha2_sigma_inv(unlabelled,:);
    alpha2_sigma_inv_UL = alpha2_sigma_inv_UL(:,labelled);
    alpha2_sigma_inv_UU = alpha2_sigma_inv(unlabelled,:);
    alpha2_sigma_inv_UU = alpha2_sigma_inv_UU(:,unlabelled);
    

    

    
    %alpha1_sigma_inv_derivative = alpha1_sigma_inv_LL - (Q_LU/Q_UU)*alpha1_sigma_inv_UL - ((alpha1_sigma_inv_LU  - (Q_LU/Q_UU) * alpha1_sigma_inv_UU) / Q_UU) * Q_UL;
    %alpha2_sigma_inv_derivative = alpha2_sigma_inv_LL - (Q_LU/Q_UU)*alpha2_sigma_inv_UL - ((alpha2_sigma_inv_LU  - (Q_LU/Q_UU) * alpha2_sigma_inv_UU) / Q_UU) * Q_UL;
    
    alpha1_sigma_inv_derivative = alpha1_sigma_inv_LL - (alpha1_sigma_inv_LU / Q_UU) * Q_UL + ...
        (QLU_inv_QUU) * (alpha1_sigma_inv_UU / Q_UU) * Q_UL - (QLU_inv_QUU) * alpha1_sigma_inv_UL; 
    
    alpha2_sigma_inv_derivative = alpha2_sigma_inv_LL - (alpha2_sigma_inv_LU / Q_UU) * Q_UL + ...
        (QLU_inv_QUU) * (alpha2_sigma_inv_UU / Q_UU) * Q_UL - (QLU_inv_QUU) * alpha2_sigma_inv_UL; 
      
    gradient_alpha1 = -0.5 * (truth_aeronet-mui_star)'*alpha1_sigma_inv_derivative*(truth_aeronet-mui_star) + ...
        ((2*forecast_x1)'-mui_star'*alpha1_sigma_inv_derivative)*(truth_aeronet-mui_star) + ...
        0.5*trace(sigma_inv_star \ (alpha1_sigma_inv_derivative));
    
    gradient_alpha2 = -0.5 * (truth_aeronet-mui_star)'*alpha2_sigma_inv_derivative*(truth_aeronet-mui_star) + ...
        ((2*forecast_x2)'-mui_star'*alpha2_sigma_inv_derivative)*(truth_aeronet-mui_star) + ...
        0.5*trace(sigma_inv_star \ (alpha2_sigma_inv_derivative));
    
    alpha1_new = exp(log(alpha1) + learning_rate * alpha1 * gradient_alpha1);
    alpha2_new = exp(log(alpha2) + learning_rate * alpha2 * gradient_alpha2);
    
    
    delta_alpha1 = abs(alpha1_new - alpha1);
    delta_alpha2 = abs(alpha2_new - alpha2);
   
    
    [delta_alpha1 delta_alpha2 alpha1 alpha2]
    
    %if (delta_alpha1 + delta_alpha2) < absolon
    %    break;
    %end
    
    %alpha1s(iterations,1) = alpha1;
    %alpha2s(iterations,1) = alpha2;
    %fs(iterations,1) = F;
    
    
    alpha1 = alpha1_new;
    alpha2 = alpha2_new;
    
    iterations = iterations + 1;
       
end

toc;