clear all
close all
close(findall(groot, "Type", "figure"));
%% Create Simple Deep Learning Neural Network for Classification
% This example shows how to create and train a simple convolutional neural network 
% for deep learning classification. Convolutional neural networks are essential 
% tools for deep learning, and are especially suited for image recognition.
% 
% The example demonstrates how to:
%% 
% * Load and explore image data.
% * Define the neural network architecture.
% * Specify training options.
% * Train the neural network.
% * Predict the labels of new data and calculate the classification accuracy.
%% 
% For an example showing how to interactively create and train a simple image 
% classification neural network, see <docid:nnet_gs#mw_a1e3fba3-0eb8-43c7-ae9d-d3e167943fee 
% Create Simple Image Classification Network Using Deep Network Designer>.
%% Load and Explore Image Data
% Load the digit sample data as an image datastore. |imageDatastore| automatically 
% labels the images based on folder names and stores the data as an |ImageDatastore| 
% object. An image datastore enables you to store large image data, including 
% data that does not fit in memory, and efficiently read batches of images during 
% training of a convolutional neural network.
batchsize= 4;
imds = imageDatastore('adcnetwork', 'IncludeSubfolders',true,'ReadSize',batchsize,'LabelSource','foldernames','FileExtensions','.nii','ReadFcn',@mycustomreader);
%% 
% Display some of the images in the datastore.

figure;
perm = randperm(length(imds.Files),20);
for i = 1:20
    subplot(4,5,i);
    xxx = readimage(imds,i);
    imshow(xxx(:,:,64,1 ));
end
%% 
% Calculate the number of images in each category. |labelCount| is a table that 
% contains the labels and the number of images having each label. The datastore 
% contains 1000 images for each of the digits 0-9, for a total of 10000 images. 
% You can specify the number of classes in the last fully connected layer of your 
% neural network as the |OutputSize| argument.

labelCount = countEachLabel(imds)
%% 
% You must specify the size of the images in the input layer of the neural network. 
% Check the size of the first image in |digitData|. Each image is 28-by-28-by-1 
% pixels.

img = readimage(imds,1);
numchannel = size(img,3)
%% Specify Training and Validation Sets
% Divide the data into training and validation data sets, so that each category 
% in the training set contains 750 images, and the validation set contains the 
% remaining images from each label. |splitEachLabel| splits the datastore |digitData| 
% into two new datastores, |trainDigitData| and |valDigitData|.

% LOOCV
Nloocv = 5;
cv = cvpartition( imds.Labels,'KFold',Nloocv )
%mycvmat = [ cv.training(1), cv.training(2), cv.training(3), cv.training(4), cv.training(5), cv.training(6), cv.training(7), cv.training(8)] ;
%[imds.Labels =='1', cv.training(1), cv.training(2), cv.training(3), cv.training(4), cv.training(5), cv.training(6), cv.training(7), cv.training(8), sum(mycvmat,2)] 

pocketchannels = 8;
hyperweight = [1:1:10];
hyperweight = [1, 10, 100, 1000];
hyperweight = [1, 2, 10];
% gradient is proportial to the number of classes in each fold. Weight the cases by the class imbalance ratio
hyperweight = [1];
hyperepoch  = [1:100];
hyperepoch  = [4, 8, 16, 32, 64, 128];
hyperepoch  = [128];
accuracy = zeros(length(hyperweight ),length(hyperepoch)  );
numClasses  = numel(categories(imds.Labels));
numHeads    = 4;
patchSize   = [32 32 16];              % [ph pw pd] on feature map
featChannels = 16;
embedDim    = 32;

for idweight =1:length(hyperweight )
for idepoch =1:length(hyperepoch )

inputSize   = [256 256 64 1 ];          % [H W D C]

%% 3‑D CNN STEM
stemLayers = [
    image3dInputLayer(inputSize, ...
        'Name','input', ...
        'Normalization','zscore')                                % [web:20][web:12]

    convolution3dLayer(3,featChannels, ...
        'Padding','same', ...
        'Stride',1, ...
        'Name','conv1')                                          % [web:11]
    batchNormalizationLayer('Name','bn1')
    reluLayer('Name','relu1')
    maxPooling3dLayer(2, ...
        'Stride',2, ...
        'Name','pool1')

    convolution3dLayer(3,featChannels, ...
        'Padding','same', ...
        'Stride',1, ...
        'Name','conv2')
    batchNormalizationLayer('Name','bn2')
    reluLayer('Name','relu2')
    maxPooling3dLayer(2, ...
        'Stride',2, ...
        'Name','pool2')   % -> 16x16x8xfeatChannels
];

%% 3‑D PATCH EXTRACTION (FUNCTIONLAYER)
patchLayer3D = functionLayer(@(X)patchifyFeatures3D_R25a(X,patchSize), ...
    'Formattable',true, ...
    'Name','patchify3d');

%% TOKEN EMBEDDING (LINEAR PROJECTION)
projLayers = [
    fullyConnectedLayer(embedDim,'Name','fc_embed')
    layerNormalizationLayer('Name','ln_embed')
];

%% SELF‑ATTENTION (R2025a SYNTAX)
% Core creation syntax: selfAttentionLayer(numHeads,numKeyChannels). [web:2]
attnLayers = [
    selfAttentionLayer(numHeads,embedDim, ...
        'Name','self_attn', ...
        'NumValueChannels',embedDim)
    layerNormalizationLayer('Name','ln_attn')
];

%% TOKEN AGGREGATION
aggLayers = [
    functionLayer(@tokenMeanPool3D_R25a, ...
        'Formattable',true, ...
        'Name','token_pool')
];

%% CLASSIFICATION HEAD
headLayers = [
    fullyConnectedLayer(128,'Name','fc1')
    reluLayer('Name','relu_head')
    dropoutLayer(0.5,'Name','dropout_head')
    fullyConnectedLayer(numClasses,'Name','fc_out')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')
];

%% BUILD GRAPH
lgraph = layerGraph;
lgraph = addLayers(lgraph, stemLayers);
lgraph = addLayers(lgraph, patchLayer3D);
lgraph = addLayers(lgraph, projLayers);
lgraph = addLayers(lgraph, attnLayers);
lgraph = addLayers(lgraph, aggLayers);
lgraph = addLayers(lgraph, headLayers);

lgraph = connectLayers(lgraph,'pool2','patchify3d');
lgraph = connectLayers(lgraph,'patchify3d','fc_embed');
lgraph = connectLayers(lgraph,'ln_embed','self_attn');
lgraph = connectLayers(lgraph,'ln_attn','token_pool');
lgraph = connectLayers(lgraph,'token_pool','fc1');

% TODO hack to deep copy data structures
[imdsTrain,imdsValidation] = splitEachLabel(imds,1,'randomize');
%% Define Neural Network Architecture
% Define the convolutional neural network architecture.
YPred = categorical(NaN(length(imds.Labels),1));
myactivationsone = zeros(length(imds.Labels),1);
myactivationstwo = zeros(length(imds.Labels),1);

global foldmaxaccuracy;
for iii =1:Nloocv
%for iii =1:2
disp(iii);
imdsTrain.Files = imds.Files(cv.training(iii));
tmpLabels = imds.Labels(cv.training(iii));
if (mod(length(imdsTrain.Files ),2) > 0 )
imdsTrain.Files{end+1} =imdsTrain.Files{end};
imdsTrain.Labels = [tmpLabels;tmpLabels(end)];  
else
imdsTrain.Labels = tmpLabels;
end
imdsVal.Files = imds.Files(cv.test(iii));
tmpLabels = imds.Labels(cv.test(iii));
if (mod(length(imdsVal.Files ),2) > 0 )
imdsVal.Files{end+1} =imdsVal.Files{end};
imdsVal.Labels = [tmpLabels;tmpLabels(end)];  
else
imdsVal.Labels = tmpLabels;
end
options = trainingOptions('adam', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',hyperepoch(idepoch), ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',1, ...
    'Verbose',false, ...
    'MiniBatchSize',batchsize, ...
    'L2Regularization', 1.0000e-01, ...
    'OutputNetwork','last-iteration',...'best-validation' 'last-iteration'
    'Plots','training-progress',...
    'OutputFcn',@(info)stopTraining(info ));

%% Train Neural Network Using Training Data
% Train the neural network using the architecture defined by |layers|, the training 
% data, and the training options. By default, |trainNetwork| uses a GPU if one 
% is available, otherwise, it uses a CPU. Training on a GPU requires Parallel 
% Computing Toolbox™ and a supported GPU device. For information on supported 
% devices, see <docid:distcomp_ug#mw_57e04559-0b60-42d5-ad55-e77ec5f5865f GPU 
% Support by Release>. You can also specify the execution environment by using 
% the |'ExecutionEnvironment'| name-value pair argument of |trainingOptions|.
% 
% The training progress plot shows the mini-batch loss and accuracy and the 
% validation loss and accuracy. For more information on the training progress 
% plot, see <docid:nnet_ug.mw_507458b6-14c3-4a31-884c-9f2119ff7e05 Monitor Deep 
% Learning Training Progress>. The loss is the cross-entropy loss. The accuracy 
% is the percentage of images that the neural network classifies correctly.

% analyzeNetwork(net{iii})
foldmaxaccuracy = -inf; % reset global
[net{iii}, info{iii}] = trainNetwork(imdsTrain,lgraph,options);
disp(sprintf('max val accuracy %f',max(info{iii}.ValidationAccuracy)))
%% Classify Validation Images and Compute Accuracy
% Predict the labels of the validation data using the trained neural network, 
% and calculate the final validation accuracy. Accuracy is the fraction of labels 
% that the neural network predicts correctly. In this case, more than 99% of the 
% predicted labels match the true labels of the validation set.

%% YPred(cv.test(iii)) = classify(net{iii},imdsValidation);
%% %[predictions scores]  = classify(net{iii},imdsValidation);
%% layername = 'softmax'; outputfc = activations(net{iii},imdsValidation,layername );
%% myactivationsone(cv.test(iii)) =  outputfc(1,1,1,1,:);
%% myactivationstwo(cv.test(iii)) =  outputfc(1,1,1,2,:);

  %% % here gradcam should be sensivity of softmax output with respect to inputs. Looks like ADC was most influencial but very non intuitive.
  %% for jjj = 1:length(imdsValidation.Files)
  %% mylabel = classify(net{iii},readimage(imdsValidation,jjj));
  %% %[scoreMap,featureLayer,reductionLayer] = gradCAM(net{iii},readimage(imdsValidation,jjj),mylabel,FeatureLayer="input");
  %% [scoreMap,featureLayer,reductionLayer] = gradCAM(net{iii},readimage(imdsValidation,jjj),mylabel);
  %% niiinfo = niftiinfo(imdsValidation.Files{jjj});
  %% niiinfo.ImageSize = niiinfo.ImageSize(1:3);
  %% niiinfo.PixelDimensions = niiinfo.PixelDimensions (1:3);
  %% myfilepath = replace(imdsValidation.Files{jjj},'sanity','newmap');
  %% pathsplit = split(myfilepath,'.');
  %% command = sprintf('mkdir -p %s',pathsplit{1});
  %% status = system(command);
  %% niftiwrite(single(scoreMap),sprintf('%s/gradcam.nii',pathsplit{1}),niiinfo );
  %% %sprintf('c3d -mcs %s -o label.nii -pop -o t2.nii -pop -o adc.nii', niiinfo.Filename)
  %% end 

end

%% accuracy(idweight,idepoch ) = sum(YPred == imds.Labels)/numel(imds.Labels)
%% C = confusionmat(YPred ,imds.Labels)
end
end

%% figure(2)
%% plot(hyperepoch,accuracy(1,:) )
%% 
%% figure(3)
%% plot(myactivationsone,imds.Labels, '+')
%% figure(4)
%% histogram(myactivationsone(imds.Labels=='0'),20)
%% hold on
%% histogram(myactivationsone(imds.Labels=='1'),20)
%% 
%% table(imds.Files,myactivationsone,myactivationstwo)
%% 
% _Copyright 2018 The MathWorks, Inc._
function imagedata= mycustomreader(filename)
     vectorimage = squeeze(niftiread(filename));
     %imagedata = vectorimage(:,:,:,2).* (vectorimage(:,:,:,3) >=2);
     imagedata = vectorimage(:,:,:,2).* (vectorimage(:,:,:,4) > 0);
     %imagedata = vectorimage(:,:,:,1) + 100* vectorimage(:,:,:,3) ;
     %imagedata = vectorimage;
end

function stop = stopTraining(info)
%info.ValidationAccuracy
  global foldmaxaccuracy;
  if (info.ValidationAccuracy>foldmaxaccuracy)
     foldmaxaccuracy= info.ValidationAccuracy
  end
  if (info.Epoch>40)
    stop = info.ValidationAccuracy >= foldmaxaccuracy;
  else
    stop = info.ValidationAccuracy > 90;
  end
end
function Y = patchifyFeatures3D_R25a(X,patchSize)
% X: numeric or dlarray [H W D C N]
% Y: dlarray [patchDim x numPatches x N], format 'CBT'

    % If not dlarray, wrap and assign format.
    if ~isa(X,'dlarray')
        X = dlarray(X,'SSSCB');    % 3 spatial, channel, batch
    else
        % If X has no format, assign it.
        if isempty(dims(X))       % dims is dlarray utility in R2025a. [web:18]
            X = dlarray(extractdata(X),'SSSCB');
        end
    end

    [H,W,D,C,N] = size(X);
    ph = patchSize(1);
    pw = patchSize(2);
    pd = patchSize(3);

    H2 = floor(H/ph)*ph;
    W2 = floor(W/pw)*pw;
    D2 = floor(D/pd)*pd;
    X  = X(1:H2,1:W2,1:D2,:,:);

    % reshape -> (ph x Hblk x pw x Wblk x pd x Dblk x C x N)
    X = reshape(X,ph,H2/ph,pw,W2/pw,pd,D2/pd,C,N);

    % permute -> (ph x pw x pd x C x Hblk x Wblk x Dblk x N)
    X = permute(X,[1 3 5 7 2 4 6 8]);

    numPatches = (H2/ph)*(W2/pw)*(D2/pd);
    patchDim   = ph*pw*pd*C;

    X = reshape(X,patchDim,numPatches,N);   % [patchDim x numPatches x N]

    Y = dlarray(extractdata(X),'CBT');      % enforce 'CBT' for selfAttentionLayer. [web:2][web:18]
end

function Y = tokenMeanPool3D_R25a(X)
% X: dlarray [embedDim x numTokens x N], 'CBT'
% Y: dlarray [embedDim x N], 'CB'

    if ~isa(X,'dlarray')
        X = dlarray(X,'CBT');
    else
        if isempty(dims(X))                % unformatted dlarray. [web:18]
            X = dlarray(extractdata(X),'CBT');
        end
    end

    % mean over tokens (T is 3rd dim in 'CBT')
    Y = mean(X,3);
    Y = dlarray(extractdata(Y),'CB');      % downstream layers infer this.
end

