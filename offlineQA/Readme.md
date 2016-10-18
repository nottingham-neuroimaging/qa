# Offline QA

This folder contains a collection of code desiged to run quality assurance algorithms outside of the scanner. This has a simple GUI where you can enter such things as:

- Scan details (per scan)
- ROI for tSNR/iSNR
- Options to regenerate a HTML report

## Techincal details
To calculate the fMRI report, we calculate the tSNR maps after drift correction by default. The components of the scanner drift are modelled as a linear and quadratic function of scan number. These two additive components are regressed out by the use of a GLM.

## Current version:

Right now it has scan details (per scan) and saves it into a html. To run type:

	>> fMRI_report
	
This will load up the GUI once you have selected your files. Edit each of the notes
description, then you are finished click on "run report" to run the report. This will
generate a webpage in QA_report/index.html.

