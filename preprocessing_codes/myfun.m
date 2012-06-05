function F = myfun(x)
    global latitude1 latitude2 longitude1 longitude2
    %latitude1 = 25;
    %longitude1 = -119.851156;
    %latitude2 = 25.1283;
    %longitude2 = -120.0460;
    
    radius = 6371;
    dLat1 = degtorad(x(1)-latitude1); 
    dLon1 = degtorad(x(2)-longitude1); 
    a1 = sin(dLat1/2) * sin(dLat1/2) + cos(degtorad(latitude1)) * cos(degtorad(x(1))) * sin(dLon1/2) * sin(dLon1/2); 
    %See wiki for Atan2(http://en.wikipedia.org/wiki/Atan2) for this
    %derivation
    c1 = 2*(2 * atan( (sqrt(a1 + (1-a1)) - sqrt(1-a1)) / sqrt(a1)));
    %c = 2 * atan2(sqrt(a), sqrt(1-a)); 
    distance1 = radius * c1; 
    
    dLat2 = degtorad(x(1)-latitude2); 
    dLon2 = degtorad(x(2)-longitude2); 
    a2 = sin(dLat2/2) * sin(dLat2/2) + cos(degtorad(latitude2)) * cos(degtorad(x(1))) * sin(dLon2/2) * sin(dLon2/2); 
    c2 = 2*(2 * atan( (sqrt(a2 + (1-a2)) - sqrt(1-a2)) / sqrt(a2)));
    %c = 2 * atan2(sqrt(a), sqrt(1-a)); 
    distance2 = radius * c2; 
    
    F = [distance1-15;distance2-15;];