# output-96-images-to-pdf
an executable .command script to organize 96 well plate images to a single page PDF  

# Usage

**Installation**
You will need to have python3 preinstalled with the following packages:
pip3 install opencv-python numpy reportlab

or alternatively with pip -

pip install opencv-python numpy reportlab

**Run Script**
Copy output_DAPIGFP_96tiff_16bits.command to directory that contains total 192 files (96 DAPI and 96 GFP images) and execute command file. 

**Note**
DAPI and GFP images need to be in 16bits .tif format and named with letter and well number, such that "A1_DAPI.tif A2_DAPI.tif A1_GFP.tif A2_GFP.tif".
Image input can be obtained using cell imaging multimode reader such as BioTek Cytation5.
