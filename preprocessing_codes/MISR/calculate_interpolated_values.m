grid_path = '/home/lakesh/Aerosol/preprocessing_codes/projected_grid.mat';
load(grid_path);

source_path='/home/lakesh/Desktop/misr_final_qa_2007/';
dest_path='/home/lakesh/Desktop/misr_interpolated_2007/';

[row column] = size(grid);

year = 2007;
tic;
for day=1:365
    disp(num2str(day));
    load([source_path num2str(day) '.mat']);
    if ~isempty(data)
        p = data(:,1:2);
        t = delaunayn(p);
        f = data(:,7);
        interpolatedData = zeros(row, 7);
        %latitude
        interpolatedData(:,1) = grid(:,1);
        %longitude
        interpolatedData(:,2) = grid(:,2);
        %year
        interpolatedData(:,3) = year;
        %day
        interpolatedData(:,4) = day;
        %hour
        interpolatedData(:,5) = griddata(data(:,1),data(:,2), data(:,5),grid(:,1),grid(:,2),'nearest');
        %minute
        interpolatedData(:,6) = griddata(data(:,1),data(:,2),data(:,6),grid(:,1),grid(:,2),'nearest');
        %AOD_558
        try 
            interpolatedData(:,7) = tinterp(p, t, f, grid(:,1),grid(:,2),'linear');
        catch e

        end
        save([dest_path num2str(day) '.mat'],'interpolatedData');
    end
end

toc;


