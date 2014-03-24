function Y=region(x1,y1,I,Y,t)
seed=I(x1,y1);           %le seed
% Y=zeros(size(I));          
Y(x1,y1)=1;             
sum=seed;              
suit=1;                 %nombre de point valabe
count=1;               %calculer a chaque fois le nombre de point valabe dans les 8 voisins de point choisi
threshold=t;       %seuil
while count>0
s=0;                  
count=0;
[M,N]=size(I);
for i=1:M
   for j=1:N
     if Y(i,j)==1
      if (i-1)>0 && (i+1)<(M+1) && (j-1)>0 && (j+1)<(N+1) %le point doit pas etre au bord
       for u= -1:1                               %8 voisins
        for v= -1:1                               
          if  Y(i+u,j+v)==0 && abs(I(i+u,j+v)-seed)<=threshold %nouveau point et proche de seed
             Y(i+u,j+v)=1;                       
             count=count+1;                                
             s=s+I(i+u,j+v);                      
          end
        end 
       end
      end
     end
   end
end
suit=suit+count;                                   
sum=sum+s;                                     
seed=sum/suit;                                    %nouvelle moyenne
end
