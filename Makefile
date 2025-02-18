# Copyright (C) 2024 Gramine contributors
# SPDX-License-Identifier: BSD-3-Clause

# Build Node.js application as follows:
#
# - make               -- create non-SGX no-debug-log manifest
# - make SGX=1         -- create SGX no-debug-log manifest
# - make SGX=1 DEBUG=1 -- create SGX debug-log manifest
#
# Use `make clean` to remove Gramine-generated files and `make distclean` to
# additionally remove node_modules.

################################# CONSTANTS ###################################

# Get directory of the Makefile
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Node.js binary directory
NODEJS_DIR ?= /usr/bin

# Directory with arch-specific libraries
# the below path works for Debian/Ubuntu; for CentOS/RHEL/Fedora, you should
# overwrite this default like this: `ARCH_LIBDIR=/lib64 make`
ARCH_LIBDIR ?= /lib/x86_64-linux-gnu

# Set debug log level if DEBUG=1
ifeq ($(DEBUG),1)
GRAMINE_LOG_LEVEL = debug
else
GRAMINE_LOG_LEVEL = error
endif

################################## TARGETS ###################################

.PHONY: all
all: nodejs.manifest
ifeq ($(SGX),1)
all: nodejs.manifest.sgx nodejs.sig
endif

################################ NODE.JS MANIFEST ###############################

# The template file is a Jinja2 template and contains almost all necessary
# information to run Node.js under Gramine / Gramine-SGX. We create
# nodejs.manifest (to be run under non-SGX Gramine) by replacing variables
# in the template file using the "gramine-manifest" script.
nodejs.manifest: nodejs.manifest.template hello_world.js
	gramine-manifest \
		-Dlog_level=$(GRAMINE_LOG_LEVEL) \
		-Darch_libdir=$(ARCH_LIBDIR) \
		-Dnodejs_dir=$(NODEJS_DIR) \
		-Dnodejs_usr_share_dir=$(wildcard /usr/share/nodejs) \
		$< >$@

# Make on Ubuntu <= 20.04 doesn't support "Rules with Grouped Targets" (`&:`),
# for details on this workaround see
# https://github.com/gramineproject/gramine/blob/e8735ea06c/CI-Examples/helloworld/Makefile
nodejs.manifest.sgx nodejs.sig: sgx_sign
	@:

.INTERMEDIATE: sgx_sign
sgx_sign: nodejs.manifest
	gramine-sgx-sign \
		--manifest $< \
		--output $<.sgx \


############################### GRAMINE COMMAND ###############################

# Determine whether to use SGX or direct version of Gramine
ifeq ($(SGX),)
GRAMINE = gramine-direct
else
GRAMINE = gramine-sgx
endif

################################## CLEANUP ###################################

# Remove all generated files
.PHONY: clean
clean:
	$(RM) *.manifest *.manifest.sgx *.token *.sig

# Distclean additionally removes node_modules
.PHONY: distclean
distclean: clean
