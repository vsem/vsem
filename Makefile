# file: Makefile
# description: Build everything
# author: Andrea Vedaldi

# Copyright (C) 2007-12 Andrea Vedaldi and Brian Fulkerson.
# All rights reserved.
#
# This file is part of the VLFeat library and is made available under
# the terms of the BSD license (see the COPYING file).

# VLFEAT BUILDING INSTRUCTIONS
#
# This makefile builds VLFeat on modern UNIX boxes with the GNU
# toolchain. Mac OS X and Linux are explicitly supported, and support
# for similar architectures can be easily added.
#
# Usually, compiling VLFeat reduces to typing
#
# > cd PATH_TO_VLFEAT_SOURCE_TREE
# > make
#
# The makefile attempts to automatically determine the host
# architecture. If this fails, or if the architecture is ambiguous,
# the architecture can be set by specifying the ARCH variable. For
# instance:
#
# > make ARCH=maci64
#
# builds VLFeat for Mac OS X Intel 64 bit.
#
# !! Unforunately MATLAB mex script (at least up to version 2009B) has
# !! a bug that prevents selecting an architecture different from the
# !! default one for compilation. For instance, compiling maci64 may
# !! not work as the default architecture is maci if both 32 and 64
# !! bit MATLAB are installed. This bug is easy to fix, but requires
# !! patching the mex script. See www.vlfeat.org for detailed
# !! instructions.
#
# Other useful variables are listed below (their default value is in
# square bracked).
#
#   ARCH [undefined] - Active architecture. The supported
#       architectures are maci, maci64, glnx86, or glnxa64 (these are
#       the same architecture identifers used by MATLAB:
#       http://www.mathworks.com/help/techdoc/ref/computer.html). If
#       undefined, the makefile attempts to automatically detect the
#       architecture.
#
#   DEBUG [undefined] - If defined, turns on debugging symbols and
#       turns off optimizations
#
#   PROFILE [undefined] - If defined, turns on debugging symbols but
#       does NOT turn off optimizations.
#
#   VERB [undefined] - If defined, display in full the command
#       executed and their output.
#
#   MEX [mex]- Path to MATLAB MEX compiler. If undefined, MATLAB supprot
#       is disabled.
#
#   MKOCTFILE [undefined] - Path to Octave MKOCTFILE compiler. If undefined,
#       Octave support is disabled.
#
# To completely remove all build products use
#
# > make distclean
#
# Other useful targets include:
#
#   clean - Removes intermediate build products for the active architecture.
#   archclean - Removes all build products for the active architecture.
#   distclean - Removes all build products.
#   info - Display a list of the variables defined by the Makefile.
#   help - Print this message.
#
# VLFeat is compsed of different parts (DLL, command line utilities,
# MATLAB interface, Octave interface) so the makefile is divided in
# components, located in make/*.mak. Please check out the
# corresponding files in order to adjust parameters.

# Copyright (C) 2007-13 Andrea Vedaldi and Brian Fulkerson.
# All rights reserved.
#
# This file is part of the VLFeat library and is made available under
# the terms of the BSD license (see the COPYING file).

SHELL = /bin/bash


# Select which features to disable
# DISABLE_SSE2=yes
# DISABLE_AVX=yes
# DISABLE_THREADS=yes
# DISABLE_OPENMP=yes

# --------------------------------------------------------------------
#                                                       Error Messages
# --------------------------------------------------------------------

err_no_arch  =
err_no_arch +=$(shell echo "** Unknown host architecture '$(UNAME)'. This identifier"   1>&2)
err_no_arch +=$(shell echo "** was obtained by running 'uname -sm'. Edit the Makefile " 1>&2)
err_no_arch +=$(shell echo "** to add the appropriate configuration."                   1>&2)
err_no_arch +=config

err_internal  =$(shell echo Internal error)
err_internal +=internal

err_spaces  = $(shell echo "** VLFeat root dir VLDIR='$(VLDIR)' contains spaces."  1>&2)
err_spaces += $(shell echo "** This is not supported due to GNU Make limitations." 1>&2)
err_spaces +=spaces


# --------------------------------------------------------------------
#                                                                Build
# --------------------------------------------------------------------

# Each Makefile submodule appends appropriate dependencies to the all,
# clean, archclean, distclean, and info targets. In addition, it
# appends to the deps and bins variables the list of .d files (to be
# inclued by make as auto-dependencies) and the list of files to be
# added to the binary distribution.

include make/doc.mak

.PHONY: clean, archclean, distclean, info, help
no_dep_targets += clean archclean distclean info help

clean:
	rm -f  `find . -name '*~'`
	rm -f  `find . -name '.DS_Store'`
	rm -f  `find . -name '.gdb_history'`
	rm -f  `find . -name '._*'`
	rm -rf ./results

archclean: clean

distclean:

info:
	$(call echo-title,General settings)
	$(call dump-var,deps)
	$(call echo-var,PROFILE)
	$(call echo-var,DEBUG)
	$(call echo-var,VER)
	$(call echo-var,ARCH)
	$(call echo-var,CC)
	$(call echo-var,STD_CFLAGS)
	$(call echo-var,STD_LDFLAGS)
	$(call echo-var,DISABLE_SSE2)
	$(call echo-var,DISABLE_AVX)
	$(call echo-var,DISABLE_THREADS)
	$(call echo-var,DISABLE_OPENMP)
	@printf "\nThere are %s lines of code.\n" \
	`cat $(m_src) $(mex_src) $(dll_src) $(dll_hdr) $(bin_src) | wc -l`

# Holw help works: cat this file,
# skip the first block until an empty line is found (twice)
# print the first block until an empty line,
# remove the `# ' prefix from each remaining line

help:
	@cat Makefile | \
	sed -n '1,/^$$/!p' | \
	sed -n '1,/^$$/!p' | \
	sed -n '1,/^$$/p' | \
	sed 's/^# \{0,1\}\(.*\)$$/\1/'

# --------------------------------------------------------------------
#                                                 Include dependencies
# --------------------------------------------------------------------

.PRECIOUS: $(deps)

ifeq ($(filter $(no_dep_targets), $(MAKECMDGOALS)),)
-include $(deps)
endif
