function res=grabcut_oneshot_multi(I_sub,forgroundMask,backgroundMask,para)
    forground=extractFromMask(I_sub,forgroundMask);
    if (length(backgroundMask(:))==0)
        background=extractFromMask(I_sub,~forgroundMask);
    else
        background=extractFromMask(I_sub,backgroundMask);
    end

  
    for_mixture=GaussianMixture(forground,2);
    back_mixture=GaussianMixture(background,2);
    I_pixels=reshape(I_sub,[],size(I_sub,3));
    
    %get -log likilyhook
    for_likily=-log(evaluate_mixture(I_pixels',for_mixture));
    for_likily=reshape(for_likily,size(I_sub,1),size(I_sub,2));
    back_likily=-log(evaluate_mixture(I_pixels',back_mixture));
    back_likily=reshape(back_likily,size(I_sub,1),size(I_sub,2));
    %get diff^2
    dy=diff(I_sub);
    ndy=sum(dy.*dy,3);
    
    dx=diff(I_sub,1,2);
    ndx=sum(dx.*dx,3);

    %%
    beta=para.beta;%10;
    gamma=para.gamma;%5;

    res=graph_cut_binary_precompute(back_likily,for_likily,dx,dy,beta,gamma);
    
end