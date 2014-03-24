function shadow=getShadowMask(I,para)
    shadow=[];
    if (strcmp(para.method,'simple_kmeans'))
        shadow=getShadowMask_simple_kmeans(I,para.k);
    end
    if (strcmp(para.method,'croissance_naive'))
        I_seuil=zeros(size(I));
        s=0.15;
        %detection par seuillage
        I_seuil((I<s))=1;
        I_seuil((I>=s))=0;
        figure;
        imshow((I<s));
        tolerance=0.05;
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
        tolerance=0.08;
        seed=getShadowMask_simple_kmeans(I,5);
        shadow=region_growing(I,seed,tolerance);
        figure(),subplot(121);imshow(seed)
        subplot(122);imshow(shadow)
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