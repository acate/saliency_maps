% ac_demonstration.m
% adc's altered version of demonstration.m
% begun 2016-09-12
% 


% make a param. for which percentile of saliency map values to use when
% making cropped version of original image ("img_thresholded") below.  This
% is an INTEGER from 1 to 100.
%
% Orig. value in demonstration.m was 75

THRESH_PTILE = 95;

BASE_DIR = 'C:/Users/acate/Documents/VNLab_local/';

SCRIPT_DIR = [BASE_DIR];

INPUT_DIR = [BASE_DIR 'IAPS 2008 1-20/IAPS 1-20 Images/'];

OUTPUT_DIR = [BASE_DIR 'output_images/'];

% Cell array
IMAGE_FILE_EXTS = {...
    'jpg',
    'gif',
    'png',
    'bmp',
    };


% [Some of the original code:] ----------------

% make some parameters
params = makeGBVSParams;

% could change params like this
params.contrastwidth = .11;

% example of itti/koch saliency map call
% params.useIttiKochInsteadOfGBVS = 1;
% outitti = gbvs('samplepics/1.jpg',params);
% figure;
% subplot(1,2,1);
% imshow(imread('samplepics/1.jpg'));
% title('image');
% subplot(1,2,2);
% imshow(outitti.master_map_resized);
% title('Itti, Koch Saliency Map');
% fprintf(1,'Now waiting for user to press enter...\n');
% pause;

% example of calling gbvs() with default params and then displaying result
outMaxDim = 400; %%% named "outW" in the original script; adc altered
% out = {};

% Make struct array of directory contents
% First two entries will always be "." and ".."
f = dir(INPUT_DIR);

% Remove directories (including "." and "..") from list
f([f.isdir]) = [];

% Remove html files (which usually means that a student submitted a message
% in lieu of images).  Doing this is an alternate (and easier to code)
% method copmared to checking whether every file name has an image file
% extension.
% f([...
%     strcmpi('html',...
%         {arrayfun(@(x) x.name(end-3:end), f, 'uniformoutput', false)} ...
%             ) ...
%    ]) = [];
% 
% f([...
%     ~cellfun('isempty',regexp({f(:).name},'\.html$')) ...
%    ]) = [];



tic 
for ii = 1:uniqueStrCell

    
    
  im = imread([INPUT_DIR f(ii).name]);
  
  imDims = size(im); % can be 2 or 3 elements
  
  % include "min" to force this to be a scalar in case of equal h,w.
  biggerDim = min(find(imDims(1:2) == max(imDims(1:2))));
  
  scaleVec = [NaN, NaN];
  scaleVec(biggerDim) = outMaxDim;
  
  % resize image so that largest h,w dim equals outMaxDim, while preserving
  % aspect ratio
  imResized = imresize(im,scaleVec);


    % this is how you call gbvs
    % leaving out params reset them to all default values (from
    % algsrc/makeGBVSParams.m)
    imOut = gbvs(imResized);   
  


%   % show result in a pretty way  
%   
%   s = outMaxDim / size(im,2) ; 
%   sz = size(im); sz = sz(1:2);
%   sz = round( sz * s );
% 
%   im = imresize( im , sz , 'bicubic' );  

  saliency_map = imOut.master_map_resized; % grayscale image
  
   if ( max(imResized(:)) > 2 ) imResized = double(imResized) / 255; end
  
  % Change to "<=" to EXCLUDE salient regions instead:
  imThresh = imResized .* repmat( saliency_map >= prctile(saliency_map(:),THRESH_PTILE) , [1, 1, size(imResized,3)] );  
  

  figure;
  subplot(2,2,1);
  imshow(imResized);
  title('original image');
  
  subplot(2,2,2);
  imshow(saliency_map);
  title('GBVS map');
  
  subplot(2,2,3);
  show_imgnmap(imResized,imOut);
  title('saliency map overlayed');

  subplot(2,2,4);
  imshow(imThresh);
  title(['most salient (' num2str(THRESH_PTILE) '%ile) parts']);

  


end


toc
 