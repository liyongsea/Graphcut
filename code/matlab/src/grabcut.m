function [res,evol]=grabcut(I_sub,forgroundMask,para)
% grab cut algorithm for forground background seperation.
% para should containt the following field :
% i) max_iteration
% ii) parameters for a one shot cut:
%     - beta : gradient regulization
%     - gamma : ising regulization


    evol=[];
    mask=forgroundMask;
    for i=1:para.max_iteration
        mask=grabcut_oneshot_multi(I_sub,mask,para);
        evol(:,:,i)=mask;
    end
    res=mask;
end