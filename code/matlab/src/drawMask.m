function I_out=drawMask(I,shadow,color)
    if (size(I,3)<3)
        I_rgb=repmat(I,[1,1,3]);
    else
        I_rgb=I;
    end
    I_out=I_rgb;
    for i=1:size(color,1)
        shadow3=repmat(shadow(:,:,i),[1,1,3]);
        shadow_rgb(:,:,1)=shadow3(:,:,1)*color(i,1);
        shadow_rgb(:,:,2)=shadow3(:,:,2)*color(i,2);
        shadow_rgb(:,:,3)=shadow3(:,:,3)*color(i,3);
        I_out=I_out.*(1-shadow3)+(shadow_rgb);    
    end
    imshow(I_out);
end