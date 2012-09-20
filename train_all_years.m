function [alpha1 alpha2 beta1] = train_all_years(init_params, learning_rate)

% this version calculates predictions for both association and temporal
% interaction potential using the structure location_details found by
% calling:
% location_details = get_all_separate_inputs(quality_matches_modis_time_loc_qa_mod470_aero440, quality_matches_misr_time_loc_qab_misr446b_misr446_aero440);

% the same as version without NIPS, only that the derivative is better
% very simple, since here there are no neighbourhoods

% function [CRF_pred, params, mae] = CRF_train_v1(data_truth, data_pred,
% data_last_week, init_params)
%
%  Trains CRF, calculates parameters and predicts times. Returns error.
%  Practically the same as the first version, only here we don't use
%  linear regression predictions (provided by Coric), but use history and
%  other info as suggested by professor.

% definitions

alpha1 = init_params;
alpha2 = init_params;
beta1 = init_params;

alpha3 = 0.001;

row = 95;
column = 155;
days = 3;

N = row*column;


% Matrix to hold the index for each data point 
linearMatrix = zeros(row*column*days,4);
index = 1;

for day=1:days
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

row = 95;
column = 155;

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


QSpatial = sparse(sparseIndexX_WholeYear', sparseIndexY_WholeYear', sparseIndexValue_WholeYear', N*days, N*days);

clear sparseIndexValue sparseIndexValue_WholeYear sparseIndexX sparseIndexX_WholeYear sparseIndexY sparseIndexY_WholeYear
%%%%%%%%%%%%%%%% End of calculating QSpatial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

len = N*days;
absolon = 0.00001;

% train CRF
iterations = 1;%8786

f=zeros(100,1);

%Do the training for 100 iterations using stochastic gradient descent
tic;
while true

    %Select a year at random
    index = randi([4, 7]);
    year = ['200' num2str(index)];
    
    %Select a day at random
    index = randi([1, 365-days]);
    
    
    load(['/home/lakesh/Aerosol/collocated_misr_modis_aeronet_' num2str(year) '.mat']);
    start = (index-1)*N + 1;
    stop = start + days*N - 1;
    colloc_data = collocated_misr_modis_aeronet(start:stop,:);
    
    labelled = find(colloc_data(:,3) ~= 0);
    unlabelled = find(colloc_data(:,3) == 0);

    truth_aeronet = colloc_data(labelled, 3);
    forecast_modis = colloc_data(labelled, 2);
    forecast_misr = colloc_data(labelled, 1);


    indicator_modis = (forecast_modis ~= 0);
    indicator_misr = (forecast_misr ~= 0);

    indicator_modis_whole = (colloc_data(:,2) ~= 0);
    indicator_misr_whole = (colloc_data(:,1) ~= 0);
    indicator_dummy_whole = (colloc_data(:,2) == colloc_data(:,2));

    Q1 = alpha1 * spdiags(indicator_misr_whole, 0, len, len) + alpha2 * spdiags(indicator_modis_whole, 0, len, len) + alpha3 * spdiags(indicator_dummy_whole, 0, len, len);
    Q2 = beta1*QSpatial;
    sigma_inv = 2 * (Q1 + Q2);
    %sigma_inv = 2 * (Q1);

    Q_LL = sigma_inv(labelled,:);
    Q_LL = Q_LL(:,labelled);
    Q_UU = sigma_inv(unlabelled, :);
    Q_UU = Q_UU(:,unlabelled);
    Q_LU = sigma_inv(labelled, :);
    Q_LU = Q_LU(:, unlabelled);
    Q_UL = sigma_inv(unlabelled,:);
    Q_UL = Q_UL(:, labelled);

    sigma_star_inv = Q_LL - (Q_LU / Q_UU) * Q_UL;

    labelled_size = size(forecast_misr,1);
    b = 2 * (alpha1 * spdiags(indicator_misr, 0, labelled_size, labelled_size) * forecast_misr + alpha2 * spdiags(indicator_modis, 0, labelled_size, labelled_size) * forecast_modis);

    loc_prediction = sigma_star_inv\b;


    % association parameters alpha 
    alpha1_sigma_inv = 2 * spdiags(indicator_misr_whole, 0, len, len);
    alpha1_sigma_inv_LL = alpha1_sigma_inv(labelled,:);
    alpha1_sigma_inv_LL = alpha1_sigma_inv_LL(:,labelled);
    alpha1_sigma_inv_LU = alpha1_sigma_inv(labelled,:);
    alpha1_sigma_inv_LU = alpha1_sigma_inv_LU(:,unlabelled);
    alpha1_sigma_inv_UL = alpha1_sigma_inv(unlabelled,:);
    alpha1_sigma_inv_UL = alpha1_sigma_inv_UL(:,labelled);
    alpha1_sigma_inv_UU = alpha1_sigma_inv(unlabelled,:);
    alpha1_sigma_inv_UU = alpha1_sigma_inv_UU(:,unlabelled);

    alpha2_sigma_inv = 2 * spdiags(indicator_modis_whole, 0, len, len);
    alpha2_sigma_inv_LL = alpha2_sigma_inv(labelled,:);
    alpha2_sigma_inv_LL = alpha2_sigma_inv_LL(:,labelled);
    alpha2_sigma_inv_LU = alpha2_sigma_inv(labelled,:);
    alpha2_sigma_inv_LU = alpha2_sigma_inv_LU(:,unlabelled);
    alpha2_sigma_inv_UL = alpha2_sigma_inv(unlabelled,:);
    alpha2_sigma_inv_UL = alpha2_sigma_inv_UL(:,labelled);
    alpha2_sigma_inv_UU = alpha2_sigma_inv(unlabelled,:);
    alpha2_sigma_inv_UU = alpha2_sigma_inv_UU(:,unlabelled);

    beta1_sigma_inv = 2*QSpatial;
    beta1_sigma_inv_LL = beta1_sigma_inv(labelled,:);
    beta1_sigma_inv_LL = beta1_sigma_inv_LL(:,labelled);
    beta1_sigma_inv_LU = beta1_sigma_inv(labelled,:);
    beta1_sigma_inv_LU = beta1_sigma_inv_LU(:,unlabelled);
    beta1_sigma_inv_UL = beta1_sigma_inv(unlabelled,:);
    beta1_sigma_inv_UL = beta1_sigma_inv_UL(:,labelled);
    beta1_sigma_inv_UU = beta1_sigma_inv(unlabelled,:);
    beta1_sigma_inv_UU = beta1_sigma_inv_UU(:,unlabelled);


    clear  linearMatrix

    %alpha1_sigma_inv_derivative = alpha1_sigma_inv_LL - (Q_LU/Q_UU)*alpha1_sigma_inv_UL - ((alpha1_sigma_inv_LU  - (Q_LU/Q_UU) * alpha1_sigma_inv_UU) / Q_UU) * Q_UL;
    alpha1_sigma_inv_derivative = alpha1_sigma_inv_LL - (alpha1_sigma_inv_LU / Q_UU) * Q_UL + ...
        (Q_LU / Q_UU) * (alpha1_sigma_inv_UU / Q_UU) * Q_UL - (Q_LU / Q_UU) * alpha1_sigma_inv_UL;  

    gradient_alpha1 = -0.5 * ((truth_aeronet - loc_prediction)' * alpha1_sigma_inv_derivative * (truth_aeronet - loc_prediction)) + ...
        (2 * forecast_misr' - loc_prediction'*alpha1_sigma_inv_derivative) * (truth_aeronet - loc_prediction) + ...
        0.5 * trace(sigma_star_inv \ alpha1_sigma_inv_derivative);
    clear alpha1_sigma_inv_LL alpha1_sigma_inv_LU alpha1_sigma_inv_UL alpha1_sigma_inv_UU

    %[gradient_alpha1]

    alpha2_sigma_inv_derivative = alpha2_sigma_inv_LL - (alpha2_sigma_inv_LU / Q_UU) * Q_UL + ...
        (Q_LU / Q_UU) * (alpha2_sigma_inv_UU / Q_UU) * Q_UL - (Q_LU / Q_UU) * alpha2_sigma_inv_UL;        
    %alpha2_sigma_inv_derivative = alpha2_sigma_inv_LL - (Q_LU/Q_UU)*alpha2_sigma_inv_UL - ((alpha2_sigma_inv_LU  - (Q_LU/Q_UU) * alpha2_sigma_inv_UU) / Q_UU) * Q_UL;

    gradient_alpha2 = -0.5 * ((truth_aeronet - loc_prediction)' * alpha2_sigma_inv_derivative * (truth_aeronet - loc_prediction)) + ...
        (2 * forecast_modis' - loc_prediction'*alpha2_sigma_inv_derivative) * (truth_aeronet - loc_prediction) + ...
        0.5 * trace(sigma_star_inv \ alpha2_sigma_inv_derivative);
    %[gradient_alpha2]
    clear alpha2_sigma_inv_LL alpha2_sigma_inv_LU alpha2_sigma_inv_UL alpha2_sigma_inv_UU

    % interaction parameter beta
    beta1_sigma_inv_derivative = beta1_sigma_inv_LL - (beta1_sigma_inv_LU / Q_UU) * Q_UL + ...
       (Q_LU / Q_UU) * (beta1_sigma_inv_UU / Q_UU) * Q_UL - (Q_LU / Q_UU) * beta1_sigma_inv_UL; 
    %beta1_sigma_inv_derivative = beta1_sigma_inv_LL - (Q_LU/Q_UU)*beta1_sigma_inv_UL - ((beta1_sigma_inv_LU  - (Q_LU/Q_UU) * beta1_sigma_inv_UU) / Q_UU) * Q_UL;

    gradient_beta1 = ...
     - 0.5 * (truth_aeronet + loc_prediction)' * beta1_sigma_inv_derivative * (truth_aeronet - loc_prediction) + ...
     0.5 * trace(sigma_star_inv \ beta1_sigma_inv_derivative);
    %[gradient_beta1]

    clear beta1_sigma_inv_LL beta1_sigma_inv_LU beta1_sigma_inv_UL beta1_sigma_inv_UU

    % apply gradient information
    alpha1_new = exp(log(alpha1) + learning_rate * alpha1 * gradient_alpha1);% - 0.01*alpha1));
    alpha2_new = exp(log(alpha2) + learning_rate * alpha2 * gradient_alpha2);% - 0.01*alpha2));
    beta1_new = exp(log(beta1) + learning_rate * beta1 * gradient_beta1);% - 0.01*beta1));

    delta_alpha1 = abs(alpha1_new - alpha1);
    delta_alpha2 = abs(alpha2_new - alpha2);
    delta_beta1 = abs(beta1_new - beta1);
    
    alpha1 = alpha1_new;
    alpha2 = alpha2_new;
    beta1 = beta1_new;
    
    F = -0.5*(truth_aeronet-loc_prediction)'*sigma_star_inv*(truth_aeronet-loc_prediction) + 0.5*(2 * sum(log(diag(chol(sigma_star_inv)))));
    [F]
    %objective_function(iter)=F;
    %alpha1_array(iter)=alpha1;
    %alpha2_array(iter)=alpha2;
    
    [delta_alpha1 delta_alpha2 delta_beta1 alpha1 alpha2 beta1]
    
    if delta_alpha1 < absolon && delta_alpha2 < absolon && delta_beta1 < absolon
        break;
    end
    
    f(iterations,1) = F;
    
    iterations = iterations + 1;
    %if (delta_alpha1 < 0.00001 && delta_alpha2 < 0.00001 && delta_beta1 < 0.00001)
    %    break;
    %end; 

end
toc;

