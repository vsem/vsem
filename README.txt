			VSEM (Visual Semantics Library)
				Version 0.1

Welcome and thanks for downloading VSEM!

Here are some simple steps to install the toolbox.
From the "toolbox" folder:

	1. Run the file 'vsemSetup.m'.
	
		This will allow you to use the library, which
		already incorporates a basic image dataset to
		demonstrate the demos with.
	

Now it is already possible to test VSEM. Two demos are available: 'pascalVQDemo.m'
and 'pascalFisherDemo.m'. 
	
		
	2. Run the file 'pascalDatasetSetup.m'.
		
		The VOC Pascal dataset is downloaded and installed
		in the 'data' folder. Beware, depending on your
		internet connection, this might be a lenghty
		operation!
		

Several functionalities within the library require some paths
to be added to Matlab path. To use single portions of the code
from outside the demos:

	3. Run '+helpers/+startup/vsemStartup.m'.
	
		This can be automatized by adding
		
		run(fullfile(vsempath,'+helpers/+startup/vsemStartup.m'))
								% where vsempath is VSEM's folder.

		to Matlab 'startup.m' file, usually located in
		
		fullfile(matlabroot, 'toolbox/local')