function res=grabcut_oneshot(I_sub,forgroundMask)
    forground=I_sub(forgroundMask>0.5);
    background=I_sub(forgroundMask<0.5);

    %figure,subplot(121),hist(forground,255)
    %subplot(122),hist(background,255)

    %%

    for_mixture=GaussianMixture(forground,5);
    back_mixture=GaussianMixture(background,5);
   % x=[0:0.001:1]';
   % figure(),subplot(121),drawGaussianMixture(for_mixture,x);
   % subplot(122),drawGaussianMixture(back_mixture,x);
    %%
    beta=10;
    gamma=1;

    res=graph_cut_1Dgaussian(double(I_sub),back_mixture,for_mixture,beta,gamma);
    
end