ARCH ?= $(shell dpkg --print-architecture)
WORKING_DIR := $(shell pwd)
BUILD_DIR := $(WORKING_DIR)/build

DEB_VERSION := $(shell dpkg-parsechangelog --show-field Version -l$(WORKING_DIR)/debian/changelog)
UPSTREAM_VERSION := $(shell echo $(DEB_VERSION) | sed 's/-.*//')
DEB_SRC_DIR := $(BUILD_DIR)/etherlab-ethercat-$(UPSTREAM_VERSION)
ORIG_TAR := $(BUILD_DIR)/etherlab-ethercat_$(UPSTREAM_VERSION).orig.tar.bz2
UPSTREAM_URL := https://gitlab.com/etherlab.org/ethercat/-/releases/$(UPSTREAM_VERSION)/downloads/dist-tarballs/ethercat.tar.bz2

.PHONY: all clean source

all: $(BUILD_DIR)/.built

clean:
	rm -rf $(BUILD_DIR)

source: $(ORIG_TAR)
	cd $(BUILD_DIR) && dpkg-buildpackage -S -us -uc

$(ORIG_TAR):
	mkdir -p $(BUILD_DIR)
	if [ ! -f "$(ORIG_TAR)" ]; then \
		wget -O "$(ORIG_TAR)" "$(UPSTREAM_URL)"; \
	fi

$(DEB_SRC_DIR)/debian/rules: $(ORIG_TAR) debian/rules
	rm -rf "$(DEB_SRC_DIR)"
	mkdir -p "$(DEB_SRC_DIR)"
	tar -xf "$(ORIG_TAR)" --strip-components=1 -C "$(DEB_SRC_DIR)"
	cp -a debian "$(DEB_SRC_DIR)/"
	chmod +x "$(DEB_SRC_DIR)/debian/rules" "$(DEB_SRC_DIR)/debian/etherlab-ethercat-utils.prerm"

$(BUILD_DIR)/.built: $(DEB_SRC_DIR)/debian/rules
	cd "$(DEB_SRC_DIR)" && fakeroot dpkg-buildpackage -us -uc -b -a$(ARCH)
	touch "$(BUILD_DIR)/.built"
