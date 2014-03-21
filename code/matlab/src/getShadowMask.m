function shadow=getShadowMask(I,para)
    shadow=[];
    if (strcmp(para.method,'simple_kmeans'))
        shadow=getShadowMask_simple_kmeans(I,para.k);
    end
end

function shadow=getShadowMask_simple_kmeans(I,k)
    opts = statset('Display','final');
    [idx,ctrs] = kmeans(I(:),k,...
                    'Distance','city',...
                    'Replicates',5,...
                    'Options',opts);
    s=min(ctrs);
    shadow=I<s;
end