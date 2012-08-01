grid_path = '/home/lakesh/Aerosol/preprocessing_codes/projected_grid.mat';
load(grid_path);

source_path='/home/lakesh/Desktop/modis_final_qa_2004/';
dest_path='/home/lakesh/Desktop/modis_interpolated_2004/';

[row column] = size(grid);

year = 2004;

tic;
for day=1:365
    disp(day);
    load([source_path num2str(day) '.mat']);
    if ~isempty(data)
        p = data(:,1:2);
        t = delaunayn(p);
        f = data(:,7);
        interpolatedData = zeros(row, 8);
        interpolatedData(:,1) = grid(:,1);
        interpolatedData(:,2) = grid(:,2);
        interpolatedData(:,3) = year;
        interpolatedData(:,4) = day;
        interpolatedData(:,5) = griddata(data(:,1),data(:,2), data(:,5),grid(:,1),grid(:,2),'nearest');
        interpolatedData(:,6) = griddata(data(:,1),data(:,2),data(:,6),grid(:,1),grid(:,2),'nearest');
        try 
            interpolatedData(:,7) = tinterp(p, t, f, grid(:,1),grid(:,2),'linear');
        catch e

        end
        interpolatedData(:,8) = griddata(data(:,1),data(:,2),data(:,8),grid(:,1),grid(:,2),'nearest');
        save([dest_path num2str(day) '.mat'],'interpolatedData');
    end
end

toc;


