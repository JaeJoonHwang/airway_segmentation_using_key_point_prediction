clear all, close all, clc
FN='D:\airway\DATA';    % CBCT volume image
FNC='D:\airway\EXCEL';  % coordinates
FNS='D:\airway\sagittalMIP'; %save folder
info=dir(FN); info(1:2)=[];

COOR=zeros(315,10);
SIZE=zeros(315,2);
IMG=zeros(200,200,1,315);
for i=1:length(info)
exlname=fullfile(FNC,info(i).name); % coordinate load
exlname=[exlname, '.xlsx'];
coor=xlsread(exlname); coor(1,:)=[]; coor=coor/2;
coor2=reshape(coor,[10 1]);

[V,spatial,dim] = dicomreadVolume(fullfile(info(i).folder,info(i).name)); V=squeeze(V);
[xd,~,~]=size(V);
 if xd>600
  V=imresize3(V,0.5);
 end
V1=imrotate3(mat2gray(V),-90,[1 0 0]);

bw=Maxobject(imbinarize(V1,thr));
bw_co=Maxobject(max(bw,[],3));

center_co=(OneLineMIP(bw_co,'V','min')+OneLineMIP(bw_co,'V','max'))/2;
 
a=squeeze(max(V1(:,round(center_co)-1:round(center_co)+1,:),[],2));
[xx,yy]=size(a);
a2=a; 
a2(:,end-abs(yy-xx)+1:end)=[];  size(a2)
a2(1:40+1,:)=[];

coor2=coor;
coor2(:,2)=coor2(:,2)-40;

im=imresize(a2,[200 200]);
coor3(:,1)=coor2(:,1)*200/size(a2,2);
coor3(:,2)=coor2(:,2)*200/size(a2,1);
fig=imshow(mat2gray(im),[])
hold on;
for j=1:5
   scatter(coor3(j,1),coor3(j,2))
end

IMG_test(:,:,:,i)=im;
COOR(i,:)=reshape(coor3,[10,1]);
SIZE(i,:)=[size(a2,1) size(a2,2)]
sn=horzcat(FNS,'\',info(i).name,'.jpg')
saveas(fig,sn)  
close all
end

IMG_training=IMG(:,:,:,1:252); COOR_training=COOR(1:252,:);  % training dataset
IMG_test=IMG(:,:,:,253:end); COOR_test=COOR(253:end,:);   % test dataset
[IM_OUT,COOR_OUT]= ImageRegressionAugmentationPipelineJJ(IMG_training,COOR_training);


%% Deep learning
layers = [
    imageInputLayer([200 200 1])
    
    convolution2dLayer(3,512,'Stride',2)
	reluLayer
	convolution2dLayer(3,512,'Stride',2)
	reluLayer
    batchNormalizationLayer
    
	convolution2dLayer(3,256,'Stride',1)
	reluLayer
	convolution2dLayer(3,256,'Stride',1)
	reluLayer
    batchNormalizationLayer
    
    convolution2dLayer(3,256,'Stride',1)
	reluLayer
	convolution2dLayer(3,256,'Stride',1)
	reluLayer
    batchNormalizationLayer
	
	convolution2dLayer(3,128,'Stride',1)
	reluLayer
	convolution2dLayer(3,128,'Stride',1)
	reluLayer
    batchNormalizationLayer
	
	convolution2dLayer(3,64,'Stride',1)  %32
	reluLayer
	convolution2dLayer(3,64,'Stride',1)  %32
	reluLayer
    batchNormalizationLayer
	
    convolution2dLayer(3,40,'Stride',1)   %30
	reluLayer
	convolution2dLayer(3,40,'Stride',1)   %30
	reluLayer
    convolution2dLayer(3,20,'Stride',1)  %32
	reluLayer
	convolution2dLayer(3,20,'Stride',1)  %32
	reluLayer
	convolution2dLayer(3,10,'Stride',1)   %30
    reluLayer
	convolution2dLayer(3,10,'Stride',1)   %30
    reluLayer
    fullyConnectedLayer(10)
	regressionLayer];
	
	
miniBatchSize  = 16;
validationFrequency = floor(numel(COOR_OUT)/miniBatchSize);
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',200, ...
    'InitialLearnRate',1e-4, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false);
	
	%'ValidationData',{XValidation,YValidation}, ...
    %'ValidationFrequency',validationFrequency, ...
net = trainNetwork(IM_OUT,COOR_OUT,layers,options);


%% Confirm predicted result
k=1;
	IM=squeeze(IMG_test(:,:,:,k));
	figure,subplot(1,2,1),imshow(IM,[]); 
	coor=COOR_test(k,:); coor=reshape(coor,[5,2]);
    hold on; scatter(coor(:,1),coor(:,2));


	YPredicted = reshape(predict(net,IM),[5,2]);          % predicted point
	subplot(1,2,2),imshow(imresize(IM,[200 200]),[]);	
    hold on; scatter(200*YPredicted(:,2),200*YPredicted(:,1));