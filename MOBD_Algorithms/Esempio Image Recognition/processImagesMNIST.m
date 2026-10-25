% Modified version of the original Matlab file used in Train Variational Autoencoder (VAE) to Generate Images
%
% Class of "Metodi di Ottimizzazione per Big Data" ("Optimization Methods for Big Data")
% LM Ingegneria Informatica (Master's Degree in Computer Engineering)
% University of Rome "Tor Vergata"
%
% Author: Andrea Cristofari (e-mail: andrea.cristofari@uniroma2.it)
% Date: May 22nd, 2023

function X = processImagesMNIST(filename)

    % The MNIST processing functions extract the data from the downloaded IDX
    % files into MATLAB arrays. The processImagesMNIST function performs these
    % operations: Check if the file can be opened correctly. Obtain the magic
    % number by reading the first four bytes. The magic number is 2051 for
    % image data, and 2049 for label data. Read the next 3 sets of 4 bytes,
    % which return the number of images, the number of rows, and the number of
    % columns. Read the image data. Reshape the array and swaps the first two
    % dimensions due to the fact that the data was being read in column major
    % format. Ensure the pixel values are in the range  [0,1] by dividing them
    % all by 255, and converts the 3-D array to a 4-D dlarray object. Close the
    % file.
    
    dataFolder = fullfile(tempdir,'mnist');
    gunzip(filename,dataFolder)
    
    [~,name,~] = fileparts(filename);
    
    [fileID,errmsg] = fopen(fullfile(dataFolder,name),'r','b');
    if fileID < 0
        error(errmsg);
    end
    
    magicNum = fread(fileID,1,'int32',0,'b');
    
    if magicNum == 2051
        
        fprintf('\nRead MNIST image data...\n')
        
        numImages = fread(fileID,1,'int32',0,'b');
        fprintf('Number of images in the dataset: %6d ...\n',numImages);
        numRows = fread(fileID,1,'int32',0,'b');
        numCols = fread(fileID,1,'int32',0,'b');
        
        X = fread(fileID,inf,'unsigned char');
        
        X = reshape(X,numCols,numRows,numImages);
        X = permute(X,[2 1 3]);
        X = X./255;
        X = reshape(X, [28,28,1,size(X,3)]);
        
    elseif magicNum == 2049
        
        fprintf('\nRead MNIST label data...\n')
        
        numImages = fread(fileID,1,'int32',0,'b');
        fprintf('Number of images in the dataset: %6d ...\n',numImages);
        
        X = fread(fileID,inf,'unsigned char');
        
        X = reshape(X,[1,size(X,1)]);
        
    else
        
        error('\nUnknown data');
        
    end
    
    fclose(fileID);
    
end