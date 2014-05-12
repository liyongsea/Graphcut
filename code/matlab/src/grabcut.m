function [res,evol]=grabcut(I,forgroundMask,backgroundMask,para)
% grab cut algorithm for forground background seperation.
% para should containt the following field :
% i) max_iteration
% ii) parameters for a one shot cut:
%     - beta : gradient regulization
%     - gamma : ising regulization


    evol=[];
    % initialization
    forground=extractFromMask(I,forgroundMask);
    if (length(backgroundMask(:))==0)
        background=extractFromMask(I,~forgroundMask);
    else
        background=extractFromMask(I,backgroundMask);
    end
    if (isfield(para,'fc'))
    for_comp=para.fc;
    else
        for_comp=5;
    end
    if (isfield(para,'bc'))
    back_comp=para.bc;
    else
        back_comp=5;
    end
    
    for_mixture=GaussianMixture(forground,for_comp);
    back_mixture=GaussianMixture(background,back_comp);
    
    i=1;
    while (i<para.max_iteration&&(length(forground)>0)&&(length(background)>0))
        % learning
        [Nan, forP]=evaluate_mixture(forground',for_mixture);
        [Nan, backP]=evaluate_mixture(background',back_mixture);
        [Nan,forR]=max(forP,[],2);
        [Nan,backR]=max(backP,[],2);
        for_mixture=GaussianMixture_idx(forground,forR);
        back_mixture=GaussianMixture_idx(background,backR);
        % segmentation
        mask=grabcut_oneshot_multi(I,for_mixture,back_mixture,para);
        evol(:,:,i)=mask;
        % assignment
        forground=extractFromMask(I,mask);
        background=extractFromMask(I,~mask);
        i=i+1;
    end
    res=mask;
end