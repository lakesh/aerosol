function [ distance ] = calculateDistance( latitude1,longitude1,latitude2,longitude2 )
    radius = 6371;
    dLat = degtorad(latitude2-latitude1); 
    
    dLon = degtorad(longitude2-longitude1); 
    
    a = sin(dLat/2) * sin(dLat/2) + cos(degtorad(latitude1)) * cos(degtorad(latitude2)) * sin(dLon/2) * sin(dLon/2); 
    
    %See wiki for Atan2(http://en.wikipedia.org/wiki/Atan2) for this
    %derivation
    %c = 2*(2 * atan( (sqrt(a + (1-a)) - sqrt(1-a)) / sqrt(a)));
    c = 2 * atan2(sqrt(a), sqrt(1-a)); 
    
    distance = radius * c; 
end

