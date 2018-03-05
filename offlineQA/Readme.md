# Offline QA

This folder contains a collection of code desiged to run quality assurance algorithms outside of the scanner. This has a simple GUI where you can enter such things as:

- Scan details (per scan)
- ROI for tSNR/iSNR
- Options to regenerate a HTML report

## Technical details
To calculate the fMRI report, we calculate the tSNR maps after drift correction by default. The components of the scanner drift are modelled as a linear and quadratic function of scan number. These two additive components are regressed out by the use of a GLM.

## Some dependencies:
+ Having freesurfer tools ready (i.e. the environment variables and the Matlab files in the path)
+ setting up the subjects-dir directory environment variable i.e.
	setenv(‘SUBJECTS_DIR’,’/path/to/subjects/dir’);
+ have a freesurfer segmentation ready. 

## Freesurfer Branch:

Right now it has scan details (per scan) and saves it into a html. To run type:

	>> fMRI_report
	
This will load up the GUI once you have selected your files. Edit each of the notes
description, then you are finished click on "run report" to run the report. This will
generate a webpage in QA_report/index.html.

### Additional notes for this branch

+ check the heat maps and change the max values etc using “options” then click on Redo HTML to check if its correct
+ Add the right subject name and then click “Freesurfer Metrics” : This will take a little while, so be patient! :o) the surfaces and figures are generated in the background so don’t expect any figures to pop up.
