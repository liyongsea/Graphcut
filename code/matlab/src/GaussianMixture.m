function mixture=GaussianMixture(X,nb_ctrs)
opts = statset('Display','final');
nb_ctrs=5;
[idx ctrs]=kmeans(X,nb_ctrs,...
                    'Distance','city',...
                    'Replicates',4,...
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
 
 xSmp=[0:0.001:1]';
 [yMix yGau]=evaluate_mixture(xSmp',mixture);


 figure(),hold on,
 for i=1:nb_ctrs
   plot(xSmp,yGau(:,i), '-b','LineWidth',1);
 end
  hold on,plot(xSmp,sum(yMix,2),'-r')
 

end