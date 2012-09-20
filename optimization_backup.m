% train CRF
function [f df] = optimization(x)

    alpha11=x(1);
    alpha21=x(2);
    alpha12=x(3);
    alpha22=x(4);
    

    total_years=2;
    number_of_days = 92;

    gradient_alpha11_array=zeros(total_years*number_of_days,1);
    gradient_alpha12_array=zeros(total_years*number_of_days,1);
    gradient_alpha21_array=zeros(total_years*number_of_days,1);
    gradient_alpha22_array=zeros(total_years*number_of_days,1);


    f_array=zeros(total_years*number_of_days,1);
    
    rows=95;
    columns=155;
    N=rows*columns;
      
      
    len = N;

    tic;
    j=1;
    for i=2005:2006

        load(['/home/lakesh/Aerosol/colloc_data_summer_MAR_' num2str(i) '.mat']);
        %collocated_data=colloc_data;
        %for j=1:number_of_days
        %    start = (j-1)*N+1;
        %    stop = start + N -1;
        %    colloc_data = collocated_data(start:stop,:);

            labelled = find(colloc_data(:,3) ~= 0);
            unlabelled = find(colloc_data(:,3) == 0);

            truth_aeronet = colloc_data(labelled, 3);
            forecast_modis = colloc_data(labelled, 2);
            forecast_misr = colloc_data(labelled, 1);


            indicator_modis_alone = (forecast_modis ~= 0 & forecast_misr == 0);
            indicator_misr_alone = (forecast_misr ~= 0  & forecast_modis == 0);
            indicator_misr_modis = (forecast_misr ~= 0  & forecast_modis ~= 0);

            indicator_modis_alone_whole = (colloc_data(:,2) ~= 0 & colloc_data(:,1) == 0);
            indicator_misr_alone_whole = (colloc_data(:,1) ~= 0 & colloc_data(:,2) == 0);
            indicator_misr_modis_whole = (colloc_data(:,2) ~= 0 & colloc_data(:,1) ~= 0);

            len=size(colloc_data,1);
            N = len;

            Q1 = alpha11 * spdiags(indicator_misr_alone_whole, 0, len, len) + alpha21 * spdiags(indicator_modis_alone_whole, 0, len, len) + alpha12 * spdiags(indicator_misr_modis_whole, 0, len, len) + alpha22 * spdiags(indicator_misr_modis_whole, 0, len, len); 
            %Q2 = beta1*QSpatial;

            sigma_inv = 2 * (Q1);

          
            %sigma_inv = 2 * (Q1+Q2);

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

            %b = 2 * (alpha11 * spdiags(indicator_misr_alone_whole, 0, len, len) * colloc_data(:,1) + alpha21 * spdiags(indicator_modis_alone_whole, 0, len, len) * colloc_data(:,2) + alpha12 * spdiags(indicator_misr_modis_whole, 0, len, len) * colloc_data(:,1) + alpha22 * spdiags(indicator_misr_modis_whole, 0, len, len) * colloc_data(:,2));

            b = 2 * (alpha11 * spdiags(indicator_misr_alone, 0, labelled_size, labelled_size) * forecast_misr + alpha21 * spdiags(indicator_modis_alone, 0, labelled_size, labelled_size) * forecast_modis + alpha12 * spdiags(indicator_misr_modis, 0, labelled_size, labelled_size) * forecast_misr + alpha22 * spdiags(indicator_misr_modis, 0, labelled_size, labelled_size) * forecast_modis)  ;

            loc_prediction = sigma_star_inv\b;
            %loc_prediction = sigma_inv\b;


            % association parameters alpha 
            alpha11_sigma_inv = 2 * spdiags(indicator_misr_alone_whole, 0, len, len);
            alpha11_sigma_inv_LL = alpha11_sigma_inv(labelled,:);
            alpha11_sigma_inv_LL = alpha11_sigma_inv_LL(:,labelled);
            alpha11_sigma_inv_LU = alpha11_sigma_inv(labelled,:);
            alpha11_sigma_inv_LU = alpha11_sigma_inv_LU(:,unlabelled);
            alpha11_sigma_inv_UL = alpha11_sigma_inv(unlabelled,:);
            alpha11_sigma_inv_UL = alpha11_sigma_inv_UL(:,labelled);
            alpha11_sigma_inv_UU = alpha11_sigma_inv(unlabelled,:);
            alpha11_sigma_inv_UU = alpha11_sigma_inv_UU(:,unlabelled);

            alpha21_sigma_inv = 2 * spdiags(indicator_modis_alone_whole, 0, len, len);
            alpha21_sigma_inv_LL = alpha21_sigma_inv(labelled,:);
            alpha21_sigma_inv_LL = alpha21_sigma_inv_LL(:,labelled);
            alpha21_sigma_inv_LU = alpha21_sigma_inv(labelled,:);
            alpha21_sigma_inv_LU = alpha21_sigma_inv_LU(:,unlabelled);
            alpha21_sigma_inv_UL = alpha21_sigma_inv(unlabelled,:);
            alpha21_sigma_inv_UL = alpha21_sigma_inv_UL(:,labelled);
            alpha21_sigma_inv_UU = alpha21_sigma_inv(unlabelled,:);
            alpha21_sigma_inv_UU = alpha21_sigma_inv_UU(:,unlabelled);


            alpha12_sigma_inv = 2 * spdiags(indicator_misr_modis_whole, 0, len, len);
            alpha12_sigma_inv_LL = alpha12_sigma_inv(labelled,:);
            alpha12_sigma_inv_LL = alpha12_sigma_inv_LL(:,labelled);
            alpha12_sigma_inv_LU = alpha12_sigma_inv(labelled,:);
            alpha12_sigma_inv_LU = alpha12_sigma_inv_LU(:,unlabelled);
            alpha12_sigma_inv_UL = alpha12_sigma_inv(unlabelled,:);
            alpha12_sigma_inv_UL = alpha12_sigma_inv_UL(:,labelled);
            alpha12_sigma_inv_UU = alpha12_sigma_inv(unlabelled,:);
            alpha12_sigma_inv_UU = alpha12_sigma_inv_UU(:,unlabelled);

            alpha22_sigma_inv = 2 * spdiags(indicator_misr_modis_whole, 0, len, len);
            alpha22_sigma_inv_LL = alpha22_sigma_inv(labelled,:);
            alpha22_sigma_inv_LL = alpha22_sigma_inv_LL(:,labelled);
            alpha22_sigma_inv_LU = alpha22_sigma_inv(labelled,:);
            alpha22_sigma_inv_LU = alpha22_sigma_inv_LU(:,unlabelled);
            alpha22_sigma_inv_UL = alpha22_sigma_inv(unlabelled,:);
            alpha22_sigma_inv_UL = alpha22_sigma_inv_UL(:,labelled);
            alpha22_sigma_inv_UU = alpha22_sigma_inv(unlabelled,:);
            alpha22_sigma_inv_UU = alpha22_sigma_inv_UU(:,unlabelled);

     
            alpha11_sigma_inv_derivative = alpha11_sigma_inv_LL - (Q_LU/Q_UU)*alpha11_sigma_inv_UL - ...
                ((alpha11_sigma_inv_LU  - (Q_LU/Q_UU) * alpha11_sigma_inv_UU) / Q_UU) * Q_UL;

            gradient_alpha11 = -0.5 * ((truth_aeronet - loc_prediction)' * alpha11_sigma_inv_derivative * (truth_aeronet - loc_prediction)) + ((2 *spdiags(indicator_misr_alone, 0, labelled_size, labelled_size)* forecast_misr)' - loc_prediction'*alpha11_sigma_inv_derivative) * (truth_aeronet - loc_prediction)+ 0.5 * trace(sigma_star_inv \ alpha11_sigma_inv_derivative);
            clear alpha11_sigma_inv_LL alpha11_sigma_inv_LU alpha11_sigma_inv_UL alpha11_sigma_inv_UU


            alpha12_sigma_inv_derivative = alpha12_sigma_inv_LL - (Q_LU/Q_UU)*alpha12_sigma_inv_UL - ...
                ((alpha12_sigma_inv_LU  - (Q_LU/Q_UU) * alpha12_sigma_inv_UU) / Q_UU) * Q_UL;

            gradient_alpha12 = -0.5 * ((truth_aeronet - loc_prediction)' * alpha12_sigma_inv_derivative * (truth_aeronet - loc_prediction)) + ((2 *spdiags(indicator_misr_modis, 0, labelled_size, labelled_size)* forecast_misr)' - loc_prediction'*alpha12_sigma_inv_derivative) * (truth_aeronet - loc_prediction)+ 0.5 * trace(sigma_star_inv \ alpha12_sigma_inv_derivative);
            clear alpha12_sigma_inv_LL alpha12_sigma_inv_LU alpha12_sigma_inv_UL alpha12_sigma_inv_UU
      


            alpha21_sigma_inv_derivative = alpha21_sigma_inv_LL - (Q_LU/Q_UU)*alpha21_sigma_inv_UL - ...
                ((alpha21_sigma_inv_LU  - (Q_LU/Q_UU) * alpha21_sigma_inv_UU) / Q_UU) * Q_UL;

            gradient_alpha21 = -0.5 * ((truth_aeronet - loc_prediction)' * alpha21_sigma_inv_derivative * (truth_aeronet - loc_prediction)) + ...
                ((2 *spdiags(indicator_modis_alone, 0, labelled_size, labelled_size)* forecast_modis)' - loc_prediction'*alpha21_sigma_inv_derivative) * (truth_aeronet - loc_prediction) +  0.5 * trace(sigma_star_inv \ alpha21_sigma_inv_derivative);

            clear alpha21_sigma_inv_LL alpha21_sigma_inv_LU alpha21_sigma_inv_UL alpha21_sigma_inv_UU





            alpha22_sigma_inv_derivative = alpha22_sigma_inv_LL - (Q_LU/Q_UU)*alpha22_sigma_inv_UL - ...
                ((alpha22_sigma_inv_LU  - (Q_LU/Q_UU) * alpha22_sigma_inv_UU) / Q_UU) * Q_UL;

            
            gradient_alpha22 = -0.5 * ((truth_aeronet - loc_prediction)' * alpha22_sigma_inv_derivative * (truth_aeronet - loc_prediction)) + ...
                ((2 *spdiags(indicator_misr_modis, 0, labelled_size, labelled_size)* forecast_modis)' - loc_prediction'*alpha22_sigma_inv_derivative) * (truth_aeronet - loc_prediction) +  0.5 * trace(sigma_star_inv \ alpha22_sigma_inv_derivative);

            clear alpha22_sigma_inv_LL alpha22_sigma_inv_LU alpha22_sigma_inv_UL alpha22_sigma_inv_UU



            gradient_alpha11_array(j) = gradient_alpha11;
            gradient_alpha12_array(j) = gradient_alpha12;  
            gradient_alpha21_array(j) = gradient_alpha21;
            gradient_alpha22_array(j) = gradient_alpha22;

            f_array(j) =  -(-0.5*(truth_aeronet-loc_prediction)'*sigma_star_inv*(truth_aeronet-loc_prediction) + 0.5*(2 * sum(log(diag(chol(sigma_star_inv))))));
            j=j+1;
        %end
        
    end
    
    f = sum(f_array);%-(-0.5*(truth_aeronet-loc_prediction)'*sigma_star_inv*(truth_aeronet-loc_prediction) + 0.5*(2 * sum(log(diag(chol(sigma_star_inv))))));
    gradient_alpha11 = sum(gradient_alpha11_array);
    gradient_alpha12 = sum(gradient_alpha12_array);
    gradient_alpha21 = sum(gradient_alpha21_array);
    gradient_alpha22 = sum(gradient_alpha22_array);

    
    df = [gradient_alpha11 gradient_alpha21 gradient_alpha12 gradient_alpha22];
    [alpha11  alpha21 alpha12 alpha22 ]
    toc;
    %[gradient_alpha1_array(1) gradient_alpha1_array(2) gradient_alpha1_array(3) gradient_alpha1_array(4)]
    
    

end

