			VSEM (Visual Semantics Library)
				Version 0.2

Welcome and thanks for downloading VSEM!

Here are some simple steps to install the toolbox.

	1. Install VLFeat 0.9.17. You can find it at www.vlfeat.org.

From the "toolbox" folder:

	2. Run the file 'vsem_setup.m'.
	
		This will allow you to use the library, which
		already incorporates a basic image dataset to
		demonstrate the demos with.
	

Now it is already possible to test VSEM by running 'bovwPascalDemo'.
		

Several functionalities within the library require some paths
to be added to Matlab path. To use single portions of the code
from outside the demos:

	3. Run 'vsem_setup.m'.
	
		This can be automatized by adding
		
		run(fullfile(vsempath,'toolbox/vsem_setup.m'))

        where vsempath is VSEM's folder, to Matlab 'startup.m' file, 
        usually located in
		
		fullfile(matlabroot, 'toolbox/local')
