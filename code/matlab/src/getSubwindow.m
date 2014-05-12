function window=getSubwindow(ROI)
% get a encompassing window of ROI
% ROI : binary image mask
% window = [x_min,x_max,y_min,y_max]
  idx=find(ROI>0.5);
  [y,x]=ind2sub(size(ROI),idx);
  window=[min(x),max(x),min(y),max(y)];
end