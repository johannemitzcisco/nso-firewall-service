# Include standard NCS build definitions and rules
include $(NCS_DIR)/src/ncs/build/include.ncs.mk
include ./simulation.mk
include $(NSO_TOOLS_DIR)/setupsimulation.mk

# Include setup makefile (autogenerated) for handling packages and netsims
include ./setup.mk

.PHONY: all start stop clean db-clean

all: packages netsim
	if [ ! -d ncs-cdb ]; then mkdir ncs-cdb; fi
	if [ ! -d init_data ]; then mkdir init_data; fi
	cp init_data/* ncs-cdb/. > /dev/null 2>&1 || true

start: stop netsim-start
	ncs

stop: netsim-stop
	ncs --stop || true

clean: packages-clean netsim-clean db-clean
	rm -rf logs/* lux_logs
	rm -rf .bundle

db-clean:
	rm -rf state/* ncs-cdb/*

# Handy CLI targets
.PHONY: cli cli-c cli-j

cli: cli-c

cli-c:
	ncs_cli -u admin -C

cli-j:
	ncs_cli -u admin


###
### HERE FOLLOWS SOME HANDY GIT TARGETS WHEN WORKING WITH REMOTE REPOS
###
.PHONY: gstat glog
gstat:
	@for i in `grep GIT_PACKAGES .build-meta 2> /dev/null | cut -d= -f2`; \
	  do \
	    echo ""; \
	    echo "--- $$i ---"; \
	    (cd "packages/$$i"; \
	    git status -uno --ignore-submodules;); \
	  done

# Set N=<n> on the command line for more log output.
N = 1
glog:
	@for i in `grep GIT_PACKAGES .build-meta 2> /dev/null | cut -d= -f2`; \
	  do \
	    echo ""; \
	    echo "--- $$i ---"; \
	    (cd "packages/$$i"; \
	     git --no-pager log -n "$(N)";); \
	    echo ""; \
	  done
