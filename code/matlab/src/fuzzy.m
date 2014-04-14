function [ objet ] = fuzzy( shadow, para )
% get the fuzzy landscape given the shadow
% para should contain the following field :
%    theta: direction of the shadow 
%    l : length of the shadow 
%    sigma : to be detailed
l=para.l;
sigma=para.sigma;
theta=para.theta;


m_se_rev=computeSE(l,theta+pi);


shadow_C=ones(size(shadow))-shadow;
shadow_C=double(shadow_C);

se_per=strel([1,1,1;1,0,1;1,1,1]);
shadow_per=imdilate(shadow,se_per)&~shadow;
shadow_per=double(shadow_per);

m_se_gaussian=fspecial('gaussian', size(m_se_rev,1), sigma);
m_se_gaussian=m_se_gaussian./max(m_se_gaussian(:));

m_se_fuzzy=m_se_rev.*m_se_gaussian;

se_fuzzy=strel(m_se_rev,m_se_fuzzy);

objet=imdilate(shadow_per,se_fuzzy).*shadow_C;
% figure;
% imagesc(objet);colormap(gray)

end

