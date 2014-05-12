function [L_s, num_s]=rangeShadow(shadow_clean)
% range the shadow component according to size
% L_s : connect component mask
% num_s : numerotation of all the components in size order
    [L_s, num] = bwlabel(shadow_clean, 8);
    num_s=[];
    size_s= [];
    for i=0:num
       shadow_i=find(L_s==i);
       if (shadow_clean(shadow_i(1)))
          num_s=[num_s i];
          size_s=[size_s length(shadow_i)];
       end
    end
    [Nan,idx]=sort(-size_s);
    num_s=num_s(idx);
%     size_s=size_s(idx)
end