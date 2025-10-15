# etherlab-ethercat Debian packages
IgH EtherCAT Master kernel modules DKMS and utils Debian packages.

The configuration files and build commands are based on [etherlab-ethercat-tools](https://aur.archlinux.org/packages/etherlab-ethercat-tools) and [etherlab-ether-dkms](https://aur.archlinux.org/packages/etherlab-ethercat-dkms) on Arch User Repository (AUR).

## Packages

This repository packages IgH EtherCAT master into two packages:

- `etherlab-ethercat-dkms`
    - DKMS package to provide kernel modules of IgH EtherCAT master, allowing to automatically rebuild kernel modules on new kernel updates.
- `etherlab-ethercat-utils`
    - Utils and configuration files of IgH EtherCAT master, requires DKMS package to be installed.

Non-DKMS package is not provided by this repository, since it would be kernel version-dependent.
Please directly follow IgH EtherCAT master build guide to install manually if you are not using DKMS.

## Usage

1. Install dependencies

```bash
sudo apt update
sudo apt install build-essentials linux-headers dkms -y
```

2. Build debs
```bash
git clone https://github.com/a1aw/etherlab-ethercat.git
cd etherlab-ethercat
make all
# Or, to build separately, you could:
# make utils
# make dkms
```

3. Debs available in build folder

```bash
$ ls build
etherlab-ethercat_1.6.8_amd64  etherlab-ethercat-dkms_1.6.8_amd64.deb  etherlab-ethercat-utils_1.6.8_amd64.deb
```

## License
Licensed under MIT License.
