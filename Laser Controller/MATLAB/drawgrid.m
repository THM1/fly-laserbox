%function drawgrid(xRange, yRange)
function drawgrid(gridSpace)
    for i = 1:length(gridSpace)
         plot([gridSpace(i,1), gridSpace(i,3)], [gridSpace(i,2), gridSpace(i,4)], 'black');
    end
%     minX = min(xRange);
%     maxX = max(xRange);
%     
%     minY = min(yRange);
%     maxY = max(yRange);
%     
%     % Vertical
%     for i = 1:length(xRange)
%         x = xRange(i);
%         plot([x,x], [minY,maxY], 'black');
%     end
%     
%     % Horizontal
%     for i = 1:length(yRange)
%         y = yRange(i);
%         plot([minX,maxX], [y,y], 'black');
%     end
%     
end