% train CRF
function [f df] = optimization(x)
    tic
    alpha1=x(1);
    alpha2=x(2);
    beta1=x(3);
    total_years=1;
    
    years=[2007];
    
    gradient_alpha1_array=zeros(total_years,1);
    gradient_alpha2_array=zeros(total_years,1);
    f_array=zeros(total_years,1);
    gradient_beta1_array=zeros(total_years,1);
    
    global len alpha3 file_path file_prefix precision_matrix_path;
    
    load(precision_matrix_path);
    
    for i=1:total_years
        year = years(i);
        load([file_path file_prefix num2str(year) '.mat']);
        
        indicator_modis_whole = (data(:,2) ~= 0);
        indicator_misr_whole = (data(:,1) ~= 0);
        indicator_dummy_whole = (data(:,2) == data(:,2));
        
        Q1 = alpha1 * spdiags(indicator_misr_whole, 0, len, len) + alpha2 * spdiags(indicator_modis_whole, 0, len, len) + alpha3 * spdiags(indicator_dummy_whole, 0, len, len);
        QSpatial = beta1*QSpatial;       
        sigma_inv = 2 * (Q1+QSpatial);
        clear Q1 QSpatial;
        
        clear indicator_modis_whole indicator_misr_whole indicator_dummy_whole
        
        labelled = find(data(:,3) ~= 0);
        unlabelled = find(data(:,3) == 0);
                
        Q_LL = sigma_inv(labelled,:);
        Q_LL = Q_LL(:,labelled);
        Q_UU = sigma_inv(unlabelled, :);
        Q_UU = Q_UU(:,unlabelled);
        Q_LU = sigma_inv(labelled, :);
        Q_LU = Q_LU(:, unlabelled);
        Q_UL = sigma_inv(unlabelled,:);
        Q_UL = Q_UL(:, labelled);
    
        clear sigma_inv
        
        tic
        QLU_div_QUU = Q_LU/Q_UU;
        toc
        
        sigma_star_inv = Q_LL - (QLU_div_QUU) * Q_UL;
            
        clear Q_LL Q_LU
       
        truth_aeronet = data(labelled, 3);
        forecast_modis = data(labelled, 2);
        forecast_misr = data(labelled, 1);


        indicator_modis = (forecast_modis ~= 0);
        indicator_misr = (forecast_misr ~= 0);

        labelled_size = size(forecast_misr,1);
        b = 2 * (alpha1 * spdiags(indicator_misr, 0, labelled_size, labelled_size) * forecast_misr + alpha2 * spdiags(indicator_modis, 0, labelled_size, labelled_size) * forecast_modis);

        clear indicator_misr indicator_modis
        loc_prediction = sigma_star_inv\b;
        
        indicator_modis_whole = (data(:,2) ~= 0);
        indicator_misr_whole = (data(:,1) ~= 0);
        
        clear data

        % association parameters alpha 
        alpha1_sigma_inv = 2 * spdiags(indicator_misr_whole, 0, len, len);
        clear indicator_misr_whole
        alpha1_sigma_inv_LL = alpha1_sigma_inv(labelled,:);
        alpha1_sigma_inv_LL = alpha1_sigma_inv_LL(:,labelled);
        alpha1_sigma_inv_LU = alpha1_sigma_inv(labelled,:);
        alpha1_sigma_inv_LU = alpha1_sigma_inv_LU(:,unlabelled);
        alpha1_sigma_inv_UL = alpha1_sigma_inv(unlabelled,:);
        alpha1_sigma_inv_UL = alpha1_sigma_inv_UL(:,labelled);
        alpha1_sigma_inv_UU = alpha1_sigma_inv(unlabelled,:);
        alpha1_sigma_inv_UU = alpha1_sigma_inv_UU(:,unlabelled);
        
        tic
        alpha1_sigma_inv_derivative = alpha1_sigma_inv_LL - (QLU_div_QUU)*alpha1_sigma_inv_UL - ((alpha1_sigma_inv_LU  - (QLU_div_QUU) * alpha1_sigma_inv_UU) / Q_UU) * Q_UL;
        toc

        gradient_alpha1 = -0.5 * ((truth_aeronet - loc_prediction)' * alpha1_sigma_inv_derivative * (truth_aeronet - loc_prediction)) + ...
            (2 * forecast_misr' - loc_prediction'*alpha1_sigma_inv_derivative) * (truth_aeronet - loc_prediction) + ...
            0.5 * trace(sigma_star_inv \ alpha1_sigma_inv_derivative);
        clear alpha1_sigma_inv_LL alpha1_sigma_inv_LU alpha1_sigma_inv_UL alpha1_sigma_inv_UU alpha1_sigma_inv_derivative alpha1_sigma_inv
        clear forecast_misr

        alpha2_sigma_inv = 2 * spdiags(indicator_modis_whole, 0, len, len);
        clear indicator_modis_whole
        alpha2_sigma_inv_LL = alpha2_sigma_inv(labelled,:);
        alpha2_sigma_inv_LL = alpha2_sigma_inv_LL(:,labelled);
        alpha2_sigma_inv_LU = alpha2_sigma_inv(labelled,:);
        alpha2_sigma_inv_LU = alpha2_sigma_inv_LU(:,unlabelled);
        alpha2_sigma_inv_UL = alpha2_sigma_inv(unlabelled,:);
        alpha2_sigma_inv_UL = alpha2_sigma_inv_UL(:,labelled);
        alpha2_sigma_inv_UU = alpha2_sigma_inv(unlabelled,:);
        alpha2_sigma_inv_UU = alpha2_sigma_inv_UU(:,unlabelled);
        
        tic
        alpha2_sigma_inv_derivative = alpha2_sigma_inv_LL - (QLU_div_QUU)*alpha2_sigma_inv_UL - ((alpha2_sigma_inv_LU  - (QLU_div_QUU) * alpha2_sigma_inv_UU) / Q_UU) * Q_UL;
        toc

        gradient_alpha2 = -0.5 * ((truth_aeronet - loc_prediction)' * alpha2_sigma_inv_derivative * (truth_aeronet - loc_prediction)) + ...
            (2 * forecast_modis' - loc_prediction'*alpha2_sigma_inv_derivative) * (truth_aeronet - loc_prediction) + ...
            0.5 * trace(sigma_star_inv \ alpha2_sigma_inv_derivative);
        
        clear alpha2_sigma_inv_LL alpha2_sigma_inv_LU alpha2_sigma_inv_UL alpha2_sigma_inv_UU alpha2_sigma_inv_derivative alpha2_sigma_inv
        clear forecast_modis
        
        
        load(precision_matrix_path);
        beta1_sigma_inv = 2*QSpatial;
        clear QSpatial;
        beta1_sigma_inv_LL = beta1_sigma_inv(labelled,:);
        beta1_sigma_inv_LL = beta1_sigma_inv_LL(:,labelled);
        beta1_sigma_inv_LU = beta1_sigma_inv(labelled,:);
        beta1_sigma_inv_LU = beta1_sigma_inv_LU(:,unlabelled);
        beta1_sigma_inv_UL = beta1_sigma_inv(unlabelled,:);
        beta1_sigma_inv_UL = beta1_sigma_inv_UL(:,labelled);
        beta1_sigma_inv_UU = beta1_sigma_inv(unlabelled,:);
        beta1_sigma_inv_UU = beta1_sigma_inv_UU(:,unlabelled);
        
        clear beta1_sigma_inv
        
        tic
        beta1_sigma_inv_derivative = beta1_sigma_inv_LL - (QLU_div_QUU)*beta1_sigma_inv_UL - ((beta1_sigma_inv_LU  - (QLU_div_QUU) * beta1_sigma_inv_UU) / Q_UU) * Q_UL;
        toc
        
        clear Q_UL Q_UU QLU_div_QUU
        
        gradient_beta1 = ...
         - 0.5 * (truth_aeronet + loc_prediction)' * beta1_sigma_inv_derivative * (truth_aeronet - loc_prediction) + ...
         0.5 * trace(sigma_star_inv \ beta1_sigma_inv_derivative);
        
        clear beta1_sigma_inv_LL beta1_sigma_inv_LU beta1_sigma_inv_UL beta1_sigma_inv_UU

        gradient_alpha1_array(i) = gradient_alpha1;
        gradient_alpha2_array(i) = gradient_alpha2;
        gradient_beta1_array(i) = gradient_beta1;     
        f_array(i) =  -(-0.5*(truth_aeronet-loc_prediction)'*sigma_star_inv*(truth_aeronet-loc_prediction) + 0.5*(2 * sum(log(diag(chol(sigma_star_inv))))));
        
        clear truth_aeronet loc_prediction sigma_star_inv
        
    end
    
    f = sum(f_array);
    gradient_alpha1 = sum(gradient_alpha1_array);
    gradient_alpha2 = sum(gradient_alpha2_array);
    gradient_beta1 = sum(gradient_beta1_array);
    
    df = [gradient_alpha1 gradient_alpha2 gradient_beta1];
    [alpha1 alpha2 beta1]
    toc
    
end

