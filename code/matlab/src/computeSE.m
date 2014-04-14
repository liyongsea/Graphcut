function [ m_se ] = computeSE( l,teta )
%COMPUTESE Summary of this function goes here
%   Detailed explanation goes here
teta=mod(teta,2*pi);

m_se=zeros(2*l-1,2*l-1);
length=0;
i=l;
j=l;


if (teta==pi/2)
    m_se(1:l,l)=1;
elseif( teta==3*pi/2)
    m_se(l:end,l)=1;
elseif (teta==0)
    m_se(l,l:end)=1;
elseif( teta==pi)
    m_se(l,1:l)=1;
else
   if (abs(tan(teta))>=1)
       dx=l;
       dy=floor(l/abs(tan(teta)));
   else
       dy=l;
       dx=floor(l*abs(tan(teta)));
   end
   
  sx=-sign(sin(teta));
 
  sy=sign(cos(teta));
 
  err = dx - dy;
 
  while(true)
 
      m_se(i,j)=1; 
      length=length+1;
      if( length == l )
          break;
      end
 
      e2 = 2*err;
 
      if( e2 > -dy )
          err = err - dy;
          i = i + sx;
      end
 
      if( e2 < dx )
          err = err + dx;
          j = j + sy;
      end
  end
    
end





end

