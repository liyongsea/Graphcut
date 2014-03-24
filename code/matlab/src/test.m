I=imread('toulouse1_qb.gif');
Im=double(I);
figure;
imshow(I);

%%
I_seuil=zeros(size(Im));
s=10;
%detection par seuillage
I_seuil((Im<s))=1;
I_seuil((Im>=s))=0;
figure;
imshow((Im<s));

%%
%croissance de region

tolerance=5;

[M,N]=size(I);
Y=zeros(M,N);
for i=1:M
    for j=1:N
        if(I_seuil(i,j)==1 && Y(i,j)==0)
            Y=region(i,j,Im,Y,tolerance);
        end
    end
end
% Y=max(region(y,x,Im),Y);
figure,imshow(Y);
% Phi = segCroissRegion(tolerance,I,x,y);
% figure;
% imshow(Phi);
