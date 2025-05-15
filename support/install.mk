########################################################################
#
# Makefile template for Installations
#
# Time-stamp: <Saturday 2025-01-11 08:57:35 +1100 Graham Williams>
#
# Copyright (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# Define PROD and MINE if not already defined.

PROD ?= $(DEST)
MINE ?= $(DEST:$(APP)=$(USER))

# Only allow prod if in main branch.

BRANCH := $(shell git branch --show-current)

ifeq ($(BRANCH),main)
  PROD ?= $(DEST)
else
  PROD ?= $(MINE)
endif

define INSTALL_HELP
installs:

  prod     Install $(APP) into $(PROD)
  install  Install $(APP) into $(MINE)

endef
export INSTALL_HELP

help::
	@echo "$$INSTALL_HELP"

########################################################################
# LOCAL TARGETS

# Only when the dev (or main) branch is present will the app be installed
# into the appname folder on the server. Otherwise the developer's
# username is used as the install destination.

install: $(USER).install

ifeq ($(BRANCH),dev)
prod: $(APP).install
else
prod: $(USER).install
endif

# Build and install a flutter app on $(APP).host.com
#
# 1. Add a DNS A Record entry to the domain server for the new app;
# 2. Add the app name to the appropriate Caddyfile;
# 3. Clone the relevant app git repository on the host server;
# 4. For production install be sure to be on the main or dev branch as above;
# 5. `make -n prod` to check what will be done and confirm it looks okay
# 6. `make prod`

%.install:
	cp web/index.html web/index.html.bak
	perl -pi -e 's|^  <base href=.*$$|  <base href="/$*/">|' web/index.html
	flutter build web
	mv web/index.html.bak web/index.html
	if [ ! -e $(DEST:$(APP)=$*) ]; then \
		sudo mkdir $(DEST:$(APP)=$*); \
	fi
	sudo rsync -azvh build/web/ $(DEST:$(APP)=$*) --exclude *~ --exclude *.bak
	sudo chmod -R a+rX $(DEST:$(APP)=$*)
