# OVERVIEW

# INSTRUCTIONS

# GET SUBMISSIONS

## Make new directories

    ./submissions/
    ./code/
    ./output_images_ANON/

## Download from Canvas

## Unzip files

## Clean up file names

The students were instructed to name the marked-up version of their
image \[orig. name\]2.\[ext\]. However, they could really upload any old
file name. Because the main script identifies original images as any
images not ending in 2.\[ext\], it\'s necessary to fix any bad file
names manually.

It\'s OK if there is no marked up version of the original image. The
main analysis script accounts for this by writing an image of zeros if
there is no corresponding marked-up version for an original image file.

## Check for abnormal file types

Every time I have done this assignment so far, someone has uploaded a
MSWord \*.docx file with an image inserted. If you feel like it, save
that image to a proper image file.

# GET CODE

## From \[this directory\]

## Update script

# RUN IN OCTAVE

## Make sure functions are in path

## Fix any problems with compiled functions

Anthony got this error:


    >> make_saliency_maps_CogPsych_OCTAVE
    warning: load: '/home/anthony/octave/gbvs/util/mypath.mat' found by searching load path
    warning: called from
        initGBVS at line 30 column 3
        gbvs at line 37 column 16
        make_saliency_maps_CogPsych_OCTAVE at line 169 column 11
    warning: load: '/home/anthony/octave/gbvs/util/mypath.mat' found by searching load path
    error: 'mySubsample' undefined near line 23 column 10
    error: called from
        getFeatureMaps at line 23 column 8
        gbvs at line 54 column 25
        make_saliency_maps_CogPsych_OCTAVE at line 169 column 1

When Anthony tried to fix this by running the included script:

    /home/anthony/octave/gbvs/compile/gbvs_compile.m

... but got this error.

    mySubsample.cc:5:20: fatal error: matrix.h: No such file or directory
    compilation terminated.

Anthony internet searched for that error, and found this on the online
Octave documentation:

\"The first line #include \"mex.h\" makes available all of the
definitions necessary for a mex-file. One important difference between
Octave and MATLAB is that the header file \"matrix.h\" is implicitly
included through the inclusion of \"mex.h\". This is necessary to avoid
a conflict with the Octave file \"Matrix.h\" for operating systems and
compilers that don't distinguish between filenames in upper and lower
case.\"

So, Anthony altered mySubsample.cc. Top of file now reads:

    #include <stdio.h>
    #include <stdlib.h>
    #include <mex.h>
    #include <math.h>
    /* adc commented out line below for use with Octave 2018-09-24 */
    /* #include <matrix.h> */
    #include <string.h>

Then, did this in Octave

    cd('[...]/gbvs/saltoolbox/')
    mex('mySubsample.cc')

Now, when checked function with which.m:

    >> which mySubsample
    'mySubsample' is a function from the file /home/anthony/octave/gbvs/saltoolbox/mySubsample.mex

When tried to run make~saliencymapsCogPsychOCTAVE~.m again, got another
mex function error, so applied same fix until all of those errors fixed.

Recommended fix: consult the gbvs~compile~.m script, comment out the
\"matrix.h\" line in all \*.cc files it names, then run gbvs~compile~.

This needs to be done even if there are existing .mex files with same
names as the .cc files already in directory, apparently.

### GIF issues

*Then* got error:


    >> make_saliency_maps_CogPsych_OCTAVE
    warning: load: '/home/anthony/octave/gbvs/util/mypath.mat' found by searching load path
    warning: called from
        initGBVS at line 30 column 3
        gbvs at line 37 column 16
        make_saliency_maps_CogPsych_OCTAVE at line 169 column 11
    warning: load: '/home/anthony/octave/gbvs/util/mypath.mat' found by searching load path
    error: imresize: METHOD must be a string with interpolation method
    error: called from
        imresize at line 70 column 5
        make_saliency_maps_CogPsych_OCTAVE at line 194 column 4

Here is the line in question from the script, with a little context:


    gifFlag = 0;

    if ~isempty(thisMarkedInd)
        thisMarkedImFN = [INPUT_DIR names{thisMarkedInd}];
        if  isempty(regexpi(thisMarkedImFN,'\.gif$'))
            imMarked = imread([INPUT_DIR names{thisMarkedInd}]);
            imMarkedResized = imresize(imMarked,scaleVec);
        else % is .gif
            [imMarked,imMarkedMap] = imread([INPUT_DIR names{thisMarkedInd}]);
            [imMarkedResized,imMarkedResizedMap] = ...
              imresize(imMarked,imMarkedMap,scaleVec);
            gifFlag = 1;
        end
    else % Student didn't upload marked image
        imMarkedResized = zeros(size(imResized)); % image of zeros
    end

Problem is that Matlab version of imresize supports a second output arg
that is used with indexed images (like gifs), but Octave version does
not.

Solution:

I guess, even though it\'s a kludge, convert any gif images to png ahead
of time using ImageMagick on command line? Seems necessary because the
image editing site that I instructed students to use likes to save
images as gifs.

Convert all .gif images in a directory to .png:


    mogrify -format png *.gif

    rm *.gif

Then, got rid of gif-related commands in the script.

Saved current version of script to:

    ~/Google Drive/teaching/CogPsych/CogPsych_2018/in-class/saliency/code/make_saliency_maps_CogPsych_OCTAVE_orig.m

... then edited the \*OCTAVE.m file. Removed lines pertaining to gifs.

1.  Update

    \<2018-10-01 Mon>

    UPDATE: I also rewrote the code to handle indexed images, and I
    think now it might handle gifs JUST FINE.

## Run it

In the code/ directory (i.e. the dir. containing the script itself):

    >> make_saliency_maps_CogPsych_OCTAVE

# MAKE PDF OF OUTPUT IMAGES

To concatenate all image files into one PDF file. Uses ImageMagick
\"convert\"

    convert "*.png" testOut.pdf

## Remove restriction from ImageMagic policy.xml file to enable writing mulitple png files to pdf

2019-09-21

Got this error:

    anthony@anthony-VirtualBox:output_images_ANON$ convert "*.png" results.pdf
    convert-im6.q16: not authorized `results.pdf' @ error/constitute.c/WriteImage/1037.

Googled the error, and found this helpful page:

<https://askubuntu.com/questions/1081895/trouble-with-batch-conversion-of-png-to-pdf-using-convert>

Followed those instructions for removing the inhibition about writing to
PDF in particular.

Did this:

    anthony@anthony-VirtualBox:ImageMagick-6$ sudo cp -p policy.xml policy.xml.ORIG

Edited policy.xml as guided by the above noted page.

It worked.
