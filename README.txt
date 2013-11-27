			VSEM (Visual Semantics Library)
				Version 0.2

Welcome to VSEM!


VSEM is a novel toolkit which allows the extraction of 
image-based representations of concepts in an easy fashion.

VSEM is developed on top of VLFeat and it is equipped 
with state-of-the-art algorithms, from low-level feature 
detection and description up to the BoVW representation 
of images, together with a set of new routines necessary 
to move from an image-wise to a concept-wise representation 
of image content.


VSEM is distributed under the BSD license (see the LICENSE file).


QUICK START WITH MATLAB

Here are some simple steps to install the toolbox.

1. Download and install the latest VLFeat binary 
package from http://www.vlfeat.org/download/. Please 
follow carefully the installation instructions on the 
VLFeat website. You can choose between a one-time
setup and a permanent setup, but the latter is preferable.
Note that the pre-compiled binaries require MATLAB 2009B and
later.


2. Start MATLAB and run the
VSEM setup command:

> run('VSEMROOT/toolbox/vsem_setup')

Where VSEMROOT is the path to the VSEM directory
created by unpacking the archive.
	
This will allow you to use the library, which
already incorporates a basic image dataset to
demonstrate the demo with. 

Run the VSEM demo by

> bovwDemo


3. To automatically add VSEM to the MATLAB environment,
add the VSEM setup command 

run('VSEMROOT/toolbox/vsem_setup')

to the to Matlab 'startup.m' file, usually located 
in MATLABROOT/toolbox/local where MATLABROOT is 
the path to your MATLAB directory. Note that if 
'startup.m' cannot be found, you have to simply 
create one by yourself with your favourite text
editor, locate it where MATLAB can see it (e.g., 
in MATLABROOT/toolbox/local) and add the VSEM 
setup command. MATLAB will automatically run it 
the next time it will be opened.
