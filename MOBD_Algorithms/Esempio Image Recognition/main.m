% Main file to perform image recognition on MNIST dataset using a multilayer neural network
%
% Class of "Metodi di Ottimizzazione per Big Data" ("Optimization Methods for Big Data")
% LM Ingegneria Informatica (Master's Degree in Computer Engineering)
% University of Rome "Tor Vergata"
%
% Author: Andrea Cristofari (e-mail: andrea.cristofari@uniroma2.it)
% Date: May 22nd, 2023

clear all;

rng(1);

% load images (downloaded from http://yann.lecun.com/exdb/mnist)
% -------------------------------------------------------------------------
filenameImagesTrain = 'train-images-idx3-ubyte.gz';
filenameLabelsTrain = 'train-labels-idx1-ubyte.gz';
filenameImagesTest = 't10k-images-idx3-ubyte.gz';
filenameLabelsTest = 't10k-labels-idx1-ubyte.gz';

XTrain = processImagesMNIST(filenameImagesTrain);
YTrain = processImagesMNIST(filenameLabelsTrain);
XTest = processImagesMNIST(filenameImagesTest);
YTest = processImagesMNIST(filenameLabelsTest);

YTrain = categorical(YTrain);
YTest = categorical(YTest);
% -------------------------------------------------------------------------

% show images
% -------------------------------------------------------------------------
classes = categories(YTest);
n_classes = length(classes);
for i = 1:n_classes
    idx = find(YTrain==classes(i),1);
    subplot(2,5,i);
    imshow(XTrain(:,:,:,idx));
end
% -------------------------------------------------------------------------

% reshape images
% -------------------------------------------------------------------------
XTrain = reshape(XTrain,28*28,size(XTrain,4))';
XTest = reshape(XTest,28*28,size(XTest,4))';
YTrain = reshape(YTrain,[1,size(YTrain,2)])';
YTest = reshape(YTest,[1,size(YTest,2)])';
% -------------------------------------------------------------------------

% train a multilayer neural network
% -------------------------------------------------------------------------
layers = [featureInputLayer(size(XTrain,2))
          fullyConnectedLayer(256)
          reluLayer
          fullyConnectedLayer(128)
          reluLayer
          fullyConnectedLayer(n_classes)
          softmaxLayer
          classificationLayer];

options = trainingOptions('sgdm','MaxEpochs',10,'Plots','training-progress','Verbose',0);

net = trainNetwork(XTrain,YTrain,layers,options);
% -------------------------------------------------------------------------

% assess the network
% -------------------------------------------------------------------------
[YPred_train,prob_YPred_train] = classify(net,XTrain);
[YPred_test,prob_YPred_test] = classify(net,XTest);

acc_train = sum(YPred_train==YTrain)./length(YTrain);
fprintf('\n%s%.2f%s\n','accuracy on training set = ',100*acc_train,'%');
acc_test = sum(YPred_test==YTest)./length(YTest);
fprintf('\n%s%.2f%s\n','accuracy on test set = ',100*acc_test,'%');
% -------------------------------------------------------------------------