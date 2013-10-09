function sita = GetAngle(p1, p2)
    %temp = sum(p1.*p2)/(sqrt(sum(p1.^2))*sqrt(sum(p2.^2)));
    %sita = acos(temp);
    x1 = p1(1);
    y1 = p1(2);
    
    x2 = p2(1);
    y2 = p2(2);
    
    sita = atan2(x1*y2-x2*y1,x1*x2+y1*y2);
end