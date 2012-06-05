function [grid] = create_grid()
    leftBoundary = -124.848974;
    rightBoundary = -66.885444;
    topBoundary = 49.384358;
    bottomBoundary = 24.396308;
    
    distance=15;
    deltaX = 0.148124;
    
    x=leftBoundary:deltaX:rightBoundary;
    width=size(x,2);
    height=186;
    grid = zeros(height,width,2);
    
    %latitude of the lowest row
    grid(1,:,1) = bottomBoundary;
    %longitude of the lowest row
    grid(1,:,2) = x;
    
    beta=-18;
    
    global latitude1 longitude1 latitude2 longitude2;
    
    for i=2:height
        deg = km2deg(distance);
        [lat lon] = reckon(grid(i-1,1,1),grid(i-1,1,2),deg,beta);
        grid(i,1,1) = lat; 
        grid(i,1,2) = lon;
        
        for j=2:width
            latitude1 = grid(i,j-1,1);
            longitude1 = grid(i,j-1,2);
            latitude2 = grid(i-1,j,1);
            longitude2 = grid(i-1,j,2);
            x0 = [grid(i,j-1,1);grid(i-1,j,2)];
            options=optimset('Display','iter');
            [xvalue,fval] = fsolve(@myfun,x0,options);
            grid(i,j,1) = xvalue(1);
            grid(i,j,2) = xvalue(2);
        end

    end
    
    grid
    
    