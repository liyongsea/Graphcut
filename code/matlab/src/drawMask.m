function I_out=drawMask(I,shadow,color)
    if (size(I,3)<3)
        I_rgb=repmat(I,[1,1,3]);
    else
        I_rgb=I;
    end
        shadow3=repmat(shadow,[1,1,3]);
        shadow_rgb(:,:,1)=shadow3(:,:,1)*color(1);
        shadow_rgb(:,:,2)=shadow3(:,:,2)*color(2);
        shadow_rgb(:,:,3)=shadow3(:,:,3)*color(3);
        I_out=I_rgb.*(1-shadow3)+(I_rgb).*(shadow_rgb)/2;
        
    
    imshow(I_out);
end