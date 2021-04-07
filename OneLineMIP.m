function num=OneLineMIP(img,direction,minmax)
% direction: H or V (Horizontal or Vertical)
% minmax: min or max
switch direction
    case 'H'
        switch minmax
            case 'min'
              imageme=max(img,[],2);
              [kine,~]=find(imageme==1);
              num=min(kine);
            case 'max'
              imageme=max(img,[],2);
              [kine,~]=find(imageme==1);
              num=max(kine);        
        end
    case 'V'
        switch minmax
            case 'min'
              imageme=max(img,[],1);
              [~,kine]=find(imageme==1);
              num=min(kine);
            case 'max'
              imageme=max(img,[],1);
              [~,kine]=find(imageme==1);
              num=max(kine);     
        end          
end

              