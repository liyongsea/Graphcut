function I_sub=subWinImage(I,win)
  I_sub=I(win(3):win(4),win(1):win(2),:);
end