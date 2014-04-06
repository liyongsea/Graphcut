function res=grabcut(I_sub,forgroundMask)
    mask=forgroundMask;
    for i=1:10
        res=grabcut_oneshot(I_sub,mask)
    end
end