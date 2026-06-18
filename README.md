# etherlab-ethercat Debian packages

IgH EtherCAT Master kernel modules (DKMS), userspace library, development files,
and utilities packaged for Debian and Ubuntu (amd64 and arm64).

The configuration files and build commands are based on
[etherlab-ethercat-tools](https://aur.archlinux.org/packages/etherlab-ethercat-tools)
and [etherlab-ether-dkms](https://aur.archlinux.org/packages/etherlab-ethercat-dkms)
on Arch User Repository (AUR).

## Packages

This repository produces four Debian packages from upstream IgH EtherCAT releases:

| Package | Description |
|---------|-------------|
| `etherlab-ethercat` | Userspace runtime libraries (`libethercat.so`, `libfakeethercat.so`) |
| `etherlab-ethercat-dev` | Headers and development files (`ecrt.h`, pkg-config, CMake) |
| `etherlab-ethercat-dkms` | Kernel module sources built on the target via DKMS |
| `etherlab-ethercat-utils` | CLI tools, configuration, systemd unit, udev rules |

Packages are independently installable. For a full EtherCAT master stack, install
`etherlab-ethercat-dkms` and `etherlab-ethercat-utils` (plus runtime/dev as needed).

Only `etherlab-ethercat-dkms` requires the `dkms` package. Runtime and development
packages do not depend on DKMS.

## Build

### Dependencies

```bash
sudo apt update
sudo apt install -y devscripts debhelper dh-dkms dkms build-essential \
  autoconf automake libtool pkg-config fakeroot wget librtipc-dev
```

For cross-building arm64 packages on an amd64 host:

```bash
sudo apt install -y crossbuild-essential-arm64
```

### Build all packages

```bash
git clone https://github.com/a1aw/etherlab-ethercat.git
cd etherlab-ethercat
make all
```

Native build on the host architecture (amd64 or arm64):

```bash
make clean && make all
```

Cross-build for arm64:

```bash
make clean && make all ARCH=arm64
```

Output `.deb` files are written to `build/`:

```bash
ls build/*.deb
# etherlab-ethercat_1.6.8-2_amd64.deb
# etherlab-ethercat-dev_1.6.8-2_amd64.deb
# etherlab-ethercat-dkms_1.6.8-2_all.deb
# etherlab-ethercat-utils_1.6.8-2_amd64.deb
```

Version bumps: edit `debian/changelog`, not the Makefile.

## Install

Full stack (kernel modules + tools):

```bash
sudo apt install ./build/etherlab-ethercat-dkms_*.deb ./build/etherlab-ethercat-utils_*.deb
```

Development / CI (compile and link applications, no DKMS):

```bash
sudo apt install --no-install-recommends ./build/etherlab-ethercat-dev_*.deb
gcc app.c $(pkg-config --cflags --libs libethercat) -o app
```

Use `--no-install-recommends` to avoid pulling in `etherlab-ethercat-dkms` via
`etherlab-ethercat Recommends: etherlab-ethercat-dkms`.

Dry-run / simulation (no hardware master; requires [RtIPC](https://gitlab.com/etherlab.org/rtipc)):

```bash
export MY_LIB_LOCATION=/tmp/fake_lib64
mkdir -p "$MY_LIB_LOCATION"
ln -s /usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/libfakeethercat.so.1 \
  "$MY_LIB_LOCATION/libethercat.so.1"
export LD_LIBRARY_PATH="$MY_LIB_LOCATION"
export FAKE_EC_HOMEDIR=/tmp/FakeEtherCAT
mkdir -p "$FAKE_EC_HOMEDIR"
./my_application
```

See upstream [FakeEtherCAT documentation](https://docs.etherlab.org/ethercat/1.6/doxygen/libfakeethercat.html).
Build dependency `librtipc-dev` is available from the [EtherLab OBS repository](http://download.opensuse.org/repositories/science:/EtherLab/).

## License

Packaging files are licensed under the MIT License. Upstream IgH EtherCAT is
licensed under GPL-2.0 (kernel) and LGPL-2.1 (userspace). See `debian/copyright`.
