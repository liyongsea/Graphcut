function []=drawMaskContour(mask,color)
    if (nargin<2)
        color=[0 1 0];
    end
    [B,L,N,A] = bwboundaries(mask, 8);
    for nb=1:N
    boundary=B{nb};
    plot(boundary(:,2),boundary(:,1),'Color',color,'LineWidth',2);
    end

end