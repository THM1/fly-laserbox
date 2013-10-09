function E = extendSegment (P0, P1, l)
    % Starting from zero
    P = P1-P0;
    n = norm(P);
    
    % Unit vector
    u = P / n;
    
    E = P1 + u*l;
end