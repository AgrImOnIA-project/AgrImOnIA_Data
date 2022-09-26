function [gaps] = gaps(x)
%% Compute the max gaps between hourly measurement 
temp = diff([false,isnan(x)',false]); 
gaps = max(find(temp<0)-find(temp>0));   

if(isempty(gaps))
    gaps = 0; 

end



   
   