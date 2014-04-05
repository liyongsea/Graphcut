function shadow=region_growing(I,seed,tolerance)

    
    mean_intensity=mean(I(seed>0));
    se=strel(ones(3));
    neighbor_tovisit=imdilate(seed,se)&~seed;
    min_diff=min(abs(I(neighbor_tovisit>0)-mean_intensity))
    while (min_diff<tolerance&length(neighbor_tovisit)~=0)
        neighbor_index=find(neighbor_tovisit);
        good_in_neighbor=find(abs(I(neighbor_tovisit>0)-mean_intensity)<tolerance);
        neighbor_toGrow=neighbor_index(good_in_neighbor);
        seed(neighbor_toGrow)=1;
        neighbor_tovisit=imdilate(seed,se)&~seed;
        min_diff=min(abs(I(neighbor_tovisit>0)-mean_intensity));
        %sum(seed(:))
    end
    shadow=seed;

end
