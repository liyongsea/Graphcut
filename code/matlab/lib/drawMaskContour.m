function []=drawMaskContour(mask)

    [B,L,N,A] = bwboundaries(mask, 8);
    for nb=1:N
    boundary=B{nb};
    plot(boundary(:,2),boundary(:,1),'g','LineWidth',2);
    end

end