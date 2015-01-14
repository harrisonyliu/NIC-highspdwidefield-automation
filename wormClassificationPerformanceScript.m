close all
clear all

%% Loading data
load('2015.01.09 lgg1 training.mat');
lgg1 = truncated_Images;
load('2015.01.09 lipl4 training.mat');
lipl4 = truncated_Images;

%% Extracting features
lgg1Feat = wormFeatureProcessing(lgg1);
lipl4Feat = wormFeatureProcessing(lipl4);

%% Classification
[svmStruct, trainingData, trainingClass] = wormClassification(lipl4Feat,lgg1Feat);

%% Performance evaluation (10-fold cross validation)
k=5;

cvFolds = crossvalind('Kfold', trainingClass, k);   %# get indices of 10-fold CV
cp = classperf(trainingClass);                      %# init performance tracker
cpLinear = classperf(trainingClass);

for i = 1:k                                  %# for each fold
    testIdx = (cvFolds == i);                %# get indices of test instances
    trainIdx = ~testIdx;                     %# get indices training instances
    
    %# train an SVM model over training instances
    svmModel = svmtrain(trainingData(trainIdx,:), trainingClass(trainIdx), ...
        'Autoscale',true, 'Showplot',false, 'Method','QP', ...
        'BoxConstraint',2e-1, 'Kernel_Function','rbf', 'RBF_Sigma',1);
    
    svmModelLinear = svmtrain(trainingData(trainIdx,:), trainingClass(trainIdx), ...
        'Autoscale',true, 'Showplot',false);
    
    %# test using test instances
    pred = svmclassify(svmModel, trainingData(testIdx,:), 'Showplot',false);
    predLinear = svmclassify(svmModelLinear, trainingData(testIdx,:), 'Showplot',false);
    
    %# evaluate and update performance object
    cp = classperf(cp, pred, testIdx);
    cpLinear = classperf(cp, predLinear, testIdx);
end

%# get accuracy
disp(['Your classification accuracy is: ' num2str(cp.CorrectRate)])
disp(['Your linear classification accuracy is: ' num2str(cpLinear.CorrectRate)])

%# get confusion matrix
%# columns:actual, rows:predicted, last-row: unclassified instances
disp('Your confusion matrix is: ')
cp.CountingMatrix
disp('Your linear confusion matrix is: ')
cpLinear.CountingMatrix

wormFeatureBrowser(lgg1,lgg1Feat,lipl4,lipl4Feat)