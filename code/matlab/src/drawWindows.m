function []=drawWindows(win, color)

for i=1:size(win,1)
    x_begin=win(i,1);
    x_end=win(i,2);
    y_begin=win(i,3);
    y_end=win(i,4);
    x_draw=[x_begin,x_begin,x_end,x_end,x_begin];
    y_draw=[y_begin,y_end,y_end,y_begin,y_begin];
    plot(x_draw,y_draw,'Color',color,'LineWidth',2);
end

end