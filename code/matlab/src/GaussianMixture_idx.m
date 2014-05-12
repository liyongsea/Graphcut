function mixture=GaussianMixture_idx(X,idx)
R=[];

for i=1:max(idx(:))
    if ( size(find(idx==i))>0)
        R=[R idx==i];
    end
end

mixture=[];
 [mu alpha sigma P]=expectationMaximization(X,R,10,1);
 mixture.mu=mu;
 mixture.sigma=sigma;
 mixture.pi=alpha;
 

end