function forground=extractFromMask(I_sub,forgroundMask)
    forground=[];
    for i=1:size(I_sub,3)
        J=I_sub(:,:,i);
        forground(:,i)=J(forgroundMask>0.5);
    end
end