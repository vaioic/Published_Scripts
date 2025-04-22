//Author: Kristin Gallik 
//Created: April 2025
//This script opens matched images and masks, generates a line across the max diameter of each mask object and then measures the pixel values
//along the line on the image before and after a gaussian filter is applied. Used for plotting the profile of pixel values to assess changes in distribution of signal


output = getDirectory("Save Loc");
images_path = getDirectory("Images");
masks_path = getDirectory("Masks");
images_fileList = getFileList(images_path);
masks_fileList = getFileList(masks_path);
//Array.show("Before Sort", images_fileList, masks_fileList) //uncomment to see how the images are sorted natively
Array.sort(masks_fileList);
Array.sort(images_fileList);
Array.show("After Sort", images_fileList, masks_fileList) //check that the images and masks are matched correctly, comment out previous two lines if sorting is not required


//setBatchMode(true);
waitForUser;

for (i=0; i<masks_fileList.length; i++) {
	image = images_path + images_fileList[i];
	mask = masks_path + masks_fileList[i];
	run("Bio-Formats Importer", "open=mask autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	maskTitle = getTitle();
	run("Bio-Formats Importer", "open=image autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	imageTitle = getTitle(); 
	imageTitleShort = File.nameWithoutExtension; //will get name from last image opened
	run("Duplicate...", "title="+imageTitleShort+"_Gaussian duplicate channels=1");
	run("Gaussian Blur...", "sigma=1");
	gaussianImg = getTitle();
	selectWindow(maskTitle);
	run("Analyze Particles...", "exclude add");
	for (m=0; m<RoiManager.size; m++) {
		selectWindow(imageTitle);
		roiManager("select", m);
		Roi.getFeretPoints(x,y);
		makeLine(x[0], y[0], x[1], y[1]);
		//Overlay.drawLine(x[0], y[0], x[1], y[1]);
		fvalsRaw = getProfile();
		run("Clear Results");
		for (j=0; j<fvalsRaw.length; j++) {
	     	setResult("Raw", j, fvalsRaw[j]);
	  		updateResults;
		};
		selectWindow(gaussianImg);
		makeLine(x[0], y[0], x[1], y[1]);
		fvalsGaus = getProfile();
		for (k=0; k<fvalsGaus.length; k++) {
			setResult("Gaussian", k, fvalsGaus[k]);
	  		updateResults;
		};
		saveAs("Results", output + File.separator + imageTitleShort + "_Cell_"+ (m+1) + "_plotData.csv");
	};
	close("*");
	roiManager("reset");
	}
