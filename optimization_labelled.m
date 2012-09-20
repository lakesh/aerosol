% train CRF
function [f df] = optimization_labelled(x)

    alpha11=x(1);
    alpha21=x(2);
    alpha12=x(3);
    alpha22=x(4);
    

    total_years=1;
    number_of_days = 92;

    gradient_alpha11_array=zeros(total_years,1);
    gradient_alpha12_array=zeros(total_years,1);
    gradient_alpha21_array=zeros(total_years,1);
    gradient_alpha22_array=zeros(total_years,1);


    f_array=zeros(total_years,1);
    j=1;


    tic;
    for i=2007:2007
        load(['/home/lakesh/Aerosol/colloc_data_summer_labelled_BR_' num2str(i) '.mat']);

        truth_aeronet = colloc_data(:, 3);
        %truth_aeronet = sqrt(truth_aeronet);


        forecast_modis = colloc_data(:, 2);
        forecast_misr = colloc_data(:, 1);


        indicator_modis_alone = (forecast_modis ~= 0 & forecast_misr == 0);
        indicator_misr_alone = (forecast_misr ~= 0  & forecast_modis == 0);
        indicator_misr_modis = (forecast_misr ~= 0  & forecast_modis ~= 0);

        N = size(truth_aeronet,1);
        labelled_size = N;

        Q1 = alpha11 * spdiags(indicator_misr_alone, 0, N, N) + alpha21 * spdiags(indicator_modis_alone, 0, N, N) + alpha12 * spdiags(indicator_misr_modis, 0, N, N) + alpha22 * spdiags(indicator_misr_modis, 0, N, N); 
        %Q2 = beta1*QSpatial;

        sigma_inv = 2 * (Q1);
        %sigma_inv = 2 * (Q1+Q2);

        b = 2 * (alpha11 * spdiags(indicator_misr_alone, 0, labelled_size, labelled_size) * forecast_misr + alpha21 * spdiags(indicator_modis_alone, 0, labelled_size, labelled_size) * forecast_modis + alpha12 * spdiags(indicator_misr_modis, 0, labelled_size, labelled_size) * forecast_misr + alpha22 * spdiags(indicator_misr_modis, 0, labelled_size, labelled_size) * forecast_modis);

        loc_prediction = sigma_inv\b;
        %loc_prediction = (loc_prediction).^2;

        %truth_aeronet = truth_aeronet1;

        gradient_alpha11 = -0.5 * (truth_aeronet-loc_prediction)'*2*spdiags(indicator_misr_alone, 0, N, N)*(truth_aeronet-loc_prediction) + ((2*spdiags(indicator_misr_alone, 0, labelled_size, labelled_size)*forecast_misr)'-loc_prediction'*2*spdiags(indicator_misr_alone, 0, N, N))*(truth_aeronet-loc_prediction) + ...
        0.5*trace(sigma_inv \ (2*spdiags(indicator_misr_alone, 0, N, N)));



        gradient_alpha12 = -0.5 * (truth_aeronet-loc_prediction)'*2*spdiags(indicator_misr_modis, 0, N, N)*(truth_aeronet-loc_prediction) + ((2*spdiags(indicator_misr_modis, 0, labelled_size, labelled_size)*forecast_misr)'-loc_prediction'*2*spdiags(indicator_misr_modis, 0, N, N))*(truth_aeronet-loc_prediction) + ...
        0.5*trace(sigma_inv \ (2*spdiags(indicator_misr_modis, 0, N, N)));

        gradient_alpha21 = -0.5 * (truth_aeronet-loc_prediction)'*2*spdiags(indicator_modis_alone, 0, N, N)*(truth_aeronet-loc_prediction) + ((2*spdiags(indicator_modis_alone, 0, labelled_size, labelled_size)*forecast_modis)'-loc_prediction'*2*spdiags(indicator_modis_alone, 0, N, N))*(truth_aeronet-loc_prediction) + ...
        0.5*trace(sigma_inv \ (2*spdiags(indicator_modis_alone, 0, N, N)));


        gradient_alpha22 = -0.5 * (truth_aeronet-loc_prediction)'*2*spdiags(indicator_misr_modis, 0, N, N)*(truth_aeronet-loc_prediction) + ((2*spdiags(indicator_misr_modis, 0, labelled_size, labelled_size)*forecast_modis)'-loc_prediction'*2*spdiags(indicator_misr_modis, 0, N, N))*(truth_aeronet-loc_prediction) + ...
        0.5*trace(sigma_inv \ (2*spdiags(indicator_misr_modis, 0, N, N)));



        gradient_alpha11_array(j) = gradient_alpha11;
        gradient_alpha21_array(j) = gradient_alpha21;
        gradient_alpha12_array(j) = gradient_alpha12;
        gradient_alpha22_array(j) = gradient_alpha21;

        f_array(j) =  -(-0.5*(truth_aeronet-loc_prediction)'*sigma_inv*(truth_aeronet-loc_prediction) + 0.5*(2 * sum(log(diag(chol(sigma_inv))))));

        j=j+1;
    
    end
    

    
    f = sum(f_array);%-(-0.5*(truth_aeronet-loc_prediction)'*sigma_star_inv*(truth_aeronet-loc_prediction) + 0.5*(2 * sum(log(diag(chol(sigma_star_inv))))));
    gradient_alpha11 = sum(gradient_alpha11_array);
    gradient_alpha12 = sum(gradient_alpha12_array);
    gradient_alpha21 = sum(gradient_alpha21_array);
    gradient_alpha22 = sum(gradient_alpha22_array);

    
    df = [gradient_alpha11 gradient_alpha21  gradient_alpha12  gradient_alpha22];
    [alpha11 alpha21 alpha12 alpha22 ]
    toc;
    %[gradient_alpha1_array(1) gradient_alpha1_array(2) gradient_alpha1_array(3) gradient_alpha1_array(4)]
    
    

end

