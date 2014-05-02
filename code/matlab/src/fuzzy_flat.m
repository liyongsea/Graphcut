function [ objet ] = fuzzy_flat( shadow, para )
% get the fuzzy landscape given the shadow
% para should contain the following field :
%    theta: direction of the shadow 
%    l : length of the shadow 
%    s : size of ROI
l=para.l;
theta=para.theta;
s=para.size;

m_se_rev=computeSE(l*s,theta+pi);

se_fuzzy=strel(m_se_rev);
% figure,imshow(m_se_fuzzy)
objet=imdilate(shadow,se_fuzzy);
% figure;
% imagesc(objet);colormap(gray)

end



