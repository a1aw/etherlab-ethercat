PACKAGE_PREFIX=etherlab-ethercat
PACKAGE_VERSION=1.6.8
DKMS_PACKAGE=$(PACKAGE_PREFIX)-dkms
UTILS_PACKAGE=$(PACKAGE_PREFIX)-utils

WORKING_DIR=$(shell pwd)
BUILD_PATH=$(WORKING_DIR)/build
PACKAGE_BUILD_PATH=$(BUILD_PATH)/$(PACKAGE_PREFIX)_$(PACKAGE_VERSION)

PACKAGE_SRC_TAR_NAME=ethercat.tar.bz2
PACKAGE_SRC_TAR_PATH=$(PACKAGE_BUILD_PATH)/$(PACKAGE_SRC_TAR_NAME)

DKMS_BUILD_PATH=$(PACKAGE_BUILD_PATH)/$(DKMS_PACKAGE)
DKMS_BUILD_DEBIAN_PATH=$(DKMS_BUILD_PATH)/DEBIAN
DKMS_BUILD_USR_SRC_PATH=$(DKMS_BUILD_PATH)/usr/src/$(DKMS_PACKAGE)-$(PACKAGE_VERSION)

UTILS_BUILD_PATH=$(PACKAGE_BUILD_PATH)/$(UTILS_PACKAGE)
UTILS_BUILD_SRC_PATH=$(PACKAGE_BUILD_PATH)/src
UTILS_BUILD_DEBIAN_PATH=$(UTILS_BUILD_PATH)/DEBIAN

DKMS_DEB_PATH=$(PACKAGE_BUILD_PATH)/$(DKMS_PACKAGE).deb
UTILS_DEB_PATH=$(PACKAGE_BUILD_PATH)/$(UTILS_PACKAGE).deb

BUILD_JOBS=$(shell nproc)

.PHONY: all clean utils dkms

all: "$(DKMS_DEB_PATH)" "$(UTILS_DEB_PATH)"

clean:
	rm -rf $(BUILD_PATH);

utils: "$(UTILS_DEB_PATH)"

dkms: "$(DKMS_DEB_PATH)"

"$(PACKAGE_SRC_TAR_PATH)":
	mkdir -p "$(PACKAGE_BUILD_PATH)";
	if [ ! -f "$(PACKAGE_SRC_TAR_PATH)" ]; then \
		wget -O "$(PACKAGE_SRC_TAR_PATH)" https://gitlab.com/etherlab.org/ethercat/-/releases/$(PACKAGE_VERSION)/downloads/dist-tarballs/ethercat.tar.bz2; \
	fi;

"$(DKMS_DEB_PATH)": "$(PACKAGE_SRC_TAR_PATH)"
	mkdir -p "$(DKMS_BUILD_USR_SRC_PATH)";
	tar -xf "$(PACKAGE_SRC_TAR_PATH)" --strip-components=1 -C "$(DKMS_BUILD_USR_SRC_PATH)";
	sed -e "s/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/" $(WORKING_DIR)/dkms.conf > "$(DKMS_BUILD_USR_SRC_PATH)/dkms.conf";

	mkdir -p "$(DKMS_BUILD_DEBIAN_PATH)"
	sed -e "s/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/" $(WORKING_DIR)/control.dkms > "$(DKMS_BUILD_DEBIAN_PATH)/control";
	sed -e "s/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/" $(WORKING_DIR)/postinst.dkms > "$(DKMS_BUILD_DEBIAN_PATH)/postinst";
	sed -e "s/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/" $(WORKING_DIR)/prerm.dkms > "$(DKMS_BUILD_DEBIAN_PATH)/prerm";
	chmod +x "$(DKMS_BUILD_DEBIAN_PATH)/postinst";
	chmod +x "$(DKMS_BUILD_DEBIAN_PATH)/prerm";

	cd "$(PACKAGE_BUILD_PATH)"; \
	dpkg-deb --build $(DKMS_PACKAGE);

"$(UTILS_DEB_PATH)": "$(PACKAGE_SRC_TAR_PATH)"
	mkdir -p "$(UTILS_BUILD_SRC_PATH)";
	tar -xf "$(PACKAGE_SRC_TAR_PATH)" --strip-components=1 -C "$(UTILS_BUILD_SRC_PATH)";

	mkdir -p "$(UTILS_BUILD_PATH)"
	cd $(UTILS_BUILD_SRC_PATH); \
		./configure \
			--with-systemdsystemunitdir=/usr/lib/systemd/system \
			--enable-kernel=no --enable-generic=no --enable-8139too=no \
			--enable-tool=yes --enable-userlib=yes --disable-initrd; \
		make -j$(BUILD_JOBS) DESTDIR="$(UTILS_BUILD_PATH)/" install;
	
	install -Dm 0644 $(WORKING_DIR)/99-EtherCAT.rules "$(UTILS_BUILD_PATH)/usr/lib/udev/rules.d/99-EtherCAT.rules"
	install -Dm 0644 $(WORKING_DIR)/ethercat.sysusers.conf "$(UTILS_BUILD_PATH)/usr/lib/sysusers.d/ethercat.conf"
	
	mkdir -p "$(UTILS_BUILD_DEBIAN_PATH)"
	sed -e "s/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/" $(WORKING_DIR)/control.utils > "$(UTILS_BUILD_DEBIAN_PATH)/control";

	cd "$(PACKAGE_BUILD_PATH)"; \
	dpkg-deb --build $(UTILS_PACKAGE);
