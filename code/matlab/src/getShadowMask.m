function shadow=getShadowMask(I,para)
% 
    shadow=[];
    if (strcmp(para.method,'simple_kmeans'))
        shadow=getShadowMask_simple_kmeans(I,para.k);
    end
    
    if (strcmp(para.method,'croissance_naive'))
        %detection par seuillage
        I_seuil=getShadowMask_simple_kmeans(I,para.k);
        %I_seuil=I<0.1255;
        tolerance=para.tolerance;
        [M,N]=size(I);
        Y=zeros(M,N);
        for i=1:M
            for j=1:N
                if(I_seuil(i,j)==1 && Y(i,j)==0)
                    Y=region(i,j,I,Y,tolerance);
                end
            end
        end
        shadow=Y;
    end
    
    if (strcmp(para.method,'croissance'))
        tolerance=para.tolerance;
        seed=getShadowMask_simple_kmeans(I,para.k);
        shadow=region_growing(I,seed,tolerance);
    if (isfield(para,'theta'))
        m_se=computeSE(para.l,para.theta);
        shadow_clean=imopen(shadow,m_se);
    end
%         figure(),subplot(121);imshow(shadow_clean)
%         subplot(122);imshow(shadow)
        shadow=shadow_clean;
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