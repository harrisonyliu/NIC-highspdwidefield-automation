function [svmStruct, trainingData, trainingClass] = wormClassification(lipl4,lgg1)
%This function will take in a NxF array image for lipl4 and lgg1 worms
%where N is the number of training images and F is the number of features.
%Later this function will also take "test" which contains an N'xF array
%that contains the test data (N' = number of test images) and return the
%class designations under class.

temp_lipl4 = zeros(size(lipl4,1),1);
temp_lgg1 = ones(size(lgg1,1),1);
trainingClass = [temp_lipl4; temp_lgg1];
trainingData = [lipl4; lgg1];
% opt = statset('MaxIter',100000);
svmStruct = svmtrain(trainingData, trainingClass);

% %% Performance evaluation (10-fold cross validation)
% indices = crossvalind('Kfold',trainingClass,10);
% cp = classperf(trainingClass);
% for i = 1:10
%     test = (indices == i); train = ~test;
%     class = classify(trainingData(test,:),trainingData(train,:),trainingClass(train,:));
%     classperf(cp,class,test)
% end
% cp.ErrorRate