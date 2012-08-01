function plot_grid()
    latlim = [ 24 50];
    lonlim = [-135 -53];
    
    coordinate_path = '/Users/lakesh/Aerosol/preprocessing_codes/';
    
    %Load the grid coordinates
    load([coordinate_path 'grid_30x30.mat']);
    
    [row column dimension] = size(grid);
    
    figure
    ax = usamap(latlim,lonlim);
    axis off
    getm(gca,'MapProjection')
    states = shaperead('usastatehi',...
    'UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
    faceColors = makesymbolspec('Polygon',...
    {'INDEX', [1 numel(states)], ...
    'FaceColor', polcmap(numel(states))});
    geoshow(ax, states, 'SymbolSpec', faceColors)
    
    %Plot the coordinates
    for j=1:5:column
        for i=1:row
            plotm(grid(i,j,1),grid(i,j,2),'.');
        end
    end
    
    for j=1:column
        for i=1:5:row
            plotm(grid(i,j,1),grid(i,j,2),'.');
        end
    end