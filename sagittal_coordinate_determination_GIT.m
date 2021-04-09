[filename,pathname]=uigetfile('*.dcm','Select the MATLAB data file');
savepathname='D:\coordinate'; % save path for excel files
[V,spatial,dim] =dicomreadVolume(pathname); 
V1=imrotate3(mat2gray(squeeze(V)),-90,[1 0 0]);  % rotate 3D image           
S_sa = mat2gray(squeeze(V1(:, size(V,2)/2,:)));  % choose mid-sagittal plane        

figure,imshow(S_sa);
[x,y]=ginput(5);

X=vertcat(x,y);
sn=horzcat(savepathname,filename,'xlsx');
xlswrite(sn,X);
close all