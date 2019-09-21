% ac_demonstration.m
% adc's altered version of demonstration.m
% begun 2016-09-12
% 
% This script copied from "demonstration.m" from 
% http://www.vision.caltech.edu/~harel/share/gbvs.php


THRESH_PTILE = 99;

BASE_DIR = ['C:/Users/acate/Google Drive/teaching/' ...
    'CogPsych_4114_2016/in-class_assignments/' ...
    'assignment_3_image_saliency_maps/' ...
    'search_task_images/' ...
    ];

SCRIPT_DIR = [BASE_DIR 'code/'];

INPUT_DIR = [BASE_DIR];

OUTPUT_DIR = [BASE_DIR 'output_images/'];




% % Cell array
% IMAGE_FILE_EXTS = {...
%     'jpg',
%     'gif',
%     'png',
%     'bmp',
%     };


% [Some of the original code:] ----------------

% make some parameters
params = makeGBVSParams;

% could change params like this
params.contrastwidth = .11;

% itti/koch saliency map call
params.useIttiKochInsteadOfGBVS = 1;


OUT_MAX_DIM = 400; 


% Make struct array of directory contents
% First two entries will always be "." and ".."
f = dir(INPUT_DIR);

% Remove directories (including "." and "..") from list
f([f.isdir]) = [];

% IAPS images each have a copy that starts with the uber-problematic chars "._"
f([...
    ~cellfun('isempty',regexp({f(:).name},'^\._')) ...
   ]) = [];



for ii = 1:numel(f)

    fprintf('Processing image %s %i/%i\n', ...
        f(ii).name, ...
        ii, ...
        numel(f) ...
        );
    
    
  im = imread([INPUT_DIR f(ii).name]);
  
  imDims = size(im); % can be 2 or 3 elements
  
  % include "min" to force this to be a scalar in case of equal h,w.
  biggerDim = min(find(imDims(1:2) == max(imDims(1:2))));
  
  scaleVec = [NaN, NaN];
  scaleVec(biggerDim) = OUT_MAX_DIM;
  
  % resize image so that largest h,w dim equals outMaxDim, while preserving
  % aspect ratio
  imResized = imresize(im,scaleVec);

imResized = uint8(imResized);
    % this is how you call gbvs
    % leaving out params reset them to all default values (from
    % algsrc/makeGBVSParams.m)
    imOut = gbvs(imResized);   
  


  saliency_map = imOut.master_map_resized; % grayscale image
  
   if ( max(imResized(:)) > 2 ) imResized = double(imResized) / 255; end
  
  % Change to "<=" to EXCLUDE salient regions instead:
  imThresh = imResized .* repmat( saliency_map >= prctile(saliency_map(:),THRESH_PTILE) , [1, 1, size(imResized,3)] );  
  

  f1 = figure(1);
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

  
% Save the output image variable (a struct) to a .mat file, one per image.
fnBase = f(ii).name;
fnBase = fnBase(1:end-4); % because all end in ".jpg"
save([OUTPUT_DIR fnBase '_gvps.mat'],'imOut');

% Print the figure to an image file
print(f1,'-dpng',[OUTPUT_DIR fnBase '_fig']);

close(f1)

end

 