function dataOut = ImageRegressionAugmentationPipelineJJ(dataIn)

dataOut = cell([size(dataIn,1),2]);
for idx = 1:size(dataIn,1)
    
    inputImage = im2single(imresize(rgb2gray(dataIn{idx,1}),[128 128]));
    targetImage = im2single(imresize(rgb2gray(dataIn{idx,2}),[128 128]));
    
    inputImage = imnoise(inputImage,'gaussian');
    
    sigma = 1+5*rand; 
    inputImage = imgaussfilt(inputImage ,sigma); 
    
    contrastFactor = 1-0.2*rand; 
    brightnessOffset = 0.3*(rand-0.5); 
    inputImage  = inputImage .*contrastFactor + brightnessOffset;
    
    % Add randomized rotation and scale
    tform = randomAffine2d('Scale',[0.9,1.1],'Rotation',[-15 15],'XShear',[-15 15],'XTranslation',[-10 10],'YTranslation',[-10 10]);
    outputView = affineOutputView(size(inputImage),tform);
    
    % Use imwarp with the same tform and outputView to augment both images
    % the same way
    inputImage = imwarp(inputImage,tform,'OutputView',outputView);
    targetImage = imwarp(targetImage,tform,'OutputView',outputView);
    
    dataOut(idx,:) = {inputImage,targetImage};
end

end