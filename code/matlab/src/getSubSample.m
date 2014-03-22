function windows=getSubSample(im,color)
S.fH = figure('menubar','none');

S.aH = axes;
S.iH = imshow( im ); hold on
axis image;


x_begin = [];
y_begin = [];
x_end = [];
y_end = [];
windows=[];
set(S.aH,'ButtonDownFcn',@startDragFcn)
set(S.iH,'ButtonDownFcn',@startDragFcn)
set(S.fH, 'WindowButtonUpFcn', @stopDragFcn);



%%
function startDragFcn(varargin)
    set( S.fH, 'WindowButtonMotionFcn', @draggingFcn );
    pt = get(S.aH, 'CurrentPoint');
    x = pt(1,1);
    y = pt(1,2);
    x_begin = x;
    y_begin = y;
end
h=[];
h_init=false;
function draggingFcn(varargin)
    pt = get(S.aH, 'CurrentPoint');
    x = pt(1,1);
    y = pt(1,2);
    x_end = x;
    y_end = y;
    x_draw=[x_begin,x_begin,x,x,x_begin];
    y_draw=[y_begin,y,y,y_begin,y_begin];
    if (h_init)
       delete(h); 
    end
    h=plot(x_draw,y_draw,'Color',color,'LineWidth',2,'ButtonDownFcn',@startDragFcn);
    if (~h_init)
       h_init=true;
    end
    hold on
    drawnow 
end

function stopDragFcn(varargin)
    h_init=false;
    windows=[windows;x_begin,x_end,y_begin,y_end];
    set(S.fH, 'WindowButtonMotionFcn', '');  %eliminate fcn on release
   % set(S.iH,'ButtonDownFcn',@startDragFcn)
end


a = input('Press any key to terminate sampling','s');
S.fH

end
