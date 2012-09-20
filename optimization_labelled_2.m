% train CRF
function [f df] = optimization_labelled_2(x)

    alpha11=x(1);

    total_years=2;
    number_of_days = 92;

    gradient_alpha11_array=zeros(total_years,1);

    f_array=zeros(total_years,1);
    j=1;


    tic;
    for i=2007:2007
        load(['/home/lakesh/Aerosol/colloc_data_labelled_summer_MAR_' num2str(i) '.mat']);
        index=find(colloc_data(:,1) ~= 0 & colloc_data(:,2) == 0);


        colloc_data=colloc_data(index,:);

        truth_aeronet = colloc_data(:, 3);
        forecast_modis = colloc_data(:, 2);
        forecast_misr = colloc_data(:, 1);


        indicator_misr_alone = (forecast_misr ~= 0  & forecast_modis == 0);


        N = size(truth_aeronet,1);
        labelled_size = N;

        Q1 = alpha11 * spdiags(indicator_misr_alone, 0, N, N) ; 


        sigma_inv = 2 * (Q1);


        b = 2 * (alpha11 * spdiags(indicator_misr_alone, 0, labelled_size, labelled_size) * forecast_misr);

        loc_prediction = sigma_inv\b;

        gradient_alpha11 = -0.5 * (truth_aeronet-loc_prediction)'*2*spdiags(indicator_misr_alone, 0, N, N)*(truth_aeronet-loc_prediction) + ((2*spdiags(indicator_misr_alone, 0, labelled_size, labelled_size)*forecast_misr)'-loc_prediction'*2*spdiags(indicator_misr_alone, 0, N, N))*(truth_aeronet-loc_prediction) + ...
        0.5*trace(sigma_inv \ (2*spdiags(indicator_misr_alone, 0, N, N)));

        gradient_alpha11_array(j) = gradient_alpha11;

        f_array(j) =  -(-0.5*(truth_aeronet-loc_prediction)'*sigma_inv*(truth_aeronet-loc_prediction) + 0.5*(2 * sum(log(diag(chol(sigma_inv))))));

        j=j+1;
    
    end
    

    
    f = sum(f_array);
    gradient_alpha11 = sum(gradient_alpha11_array);


    
    df = [gradient_alpha11];
    [alpha11]
    toc;

    
    

end

