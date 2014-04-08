function mixture=GaussianMixture(X,nb_ctrs)
opts = statset('Display','final');
[idx ctrs]=kmeans(X,nb_ctrs,...
                    'Distance','city',...
                    'Replicates',6,...
                    'Options',opts);
R=[];%initialize R
for i=1:nb_ctrs
   R=[R idx==i];
end

mixture=[];
 [mu alpha sigma P]=expectationMaximization(X,R,10,1);
 mixture.mu=mu;
 mixture.sigma=sigma;
 mixture.pi=alpha;
 

end