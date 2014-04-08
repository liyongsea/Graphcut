function res=grabcut_oneshot(I_sub,forgroundMask,para)
    forground=I_sub(forgroundMask>0.5);
    background=I_sub(forgroundMask<0.5);

    %figure,subplot(121),hist(forground,255)
    %subplot(122),hist(background,255)

    %%
    g_componant=3;
    for_mixture=GaussianMixture(forground,g_componant);
    back_mixture=GaussianMixture(background,g_componant);
   % x=[0:0.001:1]';
   % figure(),subplot(121),drawGaussianMixture(for_mixture,x);
   % subplot(122),drawGaussianMixture(back_mixture,x);
    %%
    beta=para.beta;
    gamma=para.gamma;

    res=graph_cut_1Dgaussian(double(I_sub),back_mixture,for_mixture,beta,gamma);
    
end