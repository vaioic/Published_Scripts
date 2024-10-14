//ImageJ macro language
//written by K.L. Gallik
//use script to shift all labels in the left hemisphere by 2000 to enable parsing L and R hemisphere data in Imaris; imported label image will have seperate surface objects for L and R hemiphere brain regions
hemPath = getDir("Hemisphere");
atlasPath = getDir("Atlas");
hemSaveLoc = getDir("Relabeled Hemisphere");
atlasSaveLoc = getDir("Multiplied Atlas");
hemFileList = getFileList(hemPath);
atlasFileList = getFileList(atlasPath);

setBatchMode(true);

for (i=9; i<962; i++) {
	hemFile = hemPath + hemFileList[i];
	open(hemFile);
	hemImg = getTitle();
	hemImgClean = File.nameWithoutExtension;
	atlasFile = atlasPath + atlasFileList[i];
	open(atlasFile);
	atlasImgClean = File.nameWithoutExtension;
	atlasImg = getTitle();
	setThreshold(1, 65535, "raw");
	run("Create Mask");
	mask = getTitle();
	run("CLIJ2 Macro Extensions", "cl_device=[NVIDIA RTX A4000]");
	// multiply images
	image1 = hemImg;
	Ext.CLIJ2_push(image1);
	image2 = mask;
	Ext.CLIJ2_push(image2);
	image3 = "masked_hem";
	Ext.CLIJ2_mask(image1, image2, image3);
	Ext.CLIJ2_pull(image3);
	saveAs("tiff", hemSaveLoc + File.separator + "Masked_" + hemImgClean);
	setThreshold(2, 65535, "raw");
	run("Create Selection");
	roiManager("add");
	selectWindow(atlasImg);
	roiManager("select", 0);
	run("Add...", "value=2000");
	saveAs("tiff", atlasSaveLoc + File.separator + "Relabeled_" + atlasImgClean);
	close("*");	
	roiManager("deselect");
	roiManager("delete");
	run("Collect Garbage"); //clears memory
}
