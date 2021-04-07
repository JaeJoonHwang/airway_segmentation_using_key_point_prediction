function Img = Maxobject(Img)
stat=regionprops(Img,'Centroid','Area','PixelIdxList');
[maxValue,index] = max([stat.Area]);
[rw col]=size(stat);
for i=1:rw
    if (i~=index)
       Img(stat(i).PixelIdxList)=0; % Remove all small regions except large area index
    end
end