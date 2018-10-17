#!/usr/bin/env bash

# Exit on error
set -e

## COLORS
LRED='\033[01;31m'
LYELLOW='\033[01;33m'
NC='\033[0m' # No Color

function help()
{

    echo -e "${0} $LYELLOW<options> config_name$NC "
    echo ""
    echo -e " Options:"
    echo -e "$LYELLOW kvm virtualbox openstack kexec iso install-iso$NC"
    exit 1
}

MODE=${1}
CONFIG=${2:-config.nix} # use arg2 as config path or default to config.nix
export NIX_DISK_IMAGE
if [ ! -e "$CONFIG" ]; then
    echo "$LRED[-] Configfile \"$CONFIG\" not found$NC"
    exit 1
fi

# KVM
if [ "$MODE" == "kvm" ]; then
    VM=$( nix-build --no-out-link '<nixpkgs/nixos>' \
        -A config.system.build.vm \
        -I nixos-config=lib/vm.nix \
        --argstr imageName nit.qcow \
        -I nixcfg="${CONFIG}" \
        )
    echo "${VM}"
    eval "${VM}/bin/run-nixos-vm"

# VirtualBox
elif [ "$MODE" == "virtualbox" ]; then
   VBOX_DIR=$( nix-build --no-out-link '<nixpkgs/nixos>' \
       -A config.system.build.virtualBoxOVA \
       -I nixos-config=lib/virtualbox.nix \
       -I nixcfg="${CONFIG}" )
    echo "[+] Generated virtualbox image to: $VBOX_DIR/*.ova"

# Openstack
elif [ "$MODE" == "openstack" ]; then
OPENSTACK_DIR=$( nix-build --no-out-link '<nixpkgs/nixos>' \
    -A config.system.build.novaImage \
    -I nixos-config=lib/openstack.nix \
    -I nixcfg="${CONFIG}" )
echo "[+] Generated openstack image to: $OPENSTACK_DIR/*.qcow2"

# Kexec
elif [ "$MODE" == "kexec" ]; then
TAR_DIR=$( nix-build --no-out-link '<nixpkgs/nixos>' \
    -A config.system.build.kexec_tarball \
    -I nixos-config=lib/kexec.nix \
    -I nixcfg="${CONFIG}" )
IMG=$(find "$TAR_DIR/tarball" -type f)
echo "[+] Generated kexec image to: $IMG"

# Iso
elif [ "$MODE" == "iso" ]; then
ISO_DIR=$( nix-build --no-out-link '<nixpkgs/nixos>' \
    -A config.system.build.isoImage \
    -I nixos-config=lib/iso.nix \
    -I nixcfg="${CONFIG}" )
echo "[+] Generated iso image to: $ISO_DIR/iso/nixos.iso"

# Install Iso
elif [ "$MODE" == "install-iso" ]; then
ISO_DIR=$( nix-build --no-out-link '<nixpkgs/nixos>' \
    -A config.system.build.isoImage \
    -I nixos-config=lib/install-iso.nix \
    -I nixcfg="${CONFIG}" )
IMG=$(find "$ISO_DIR/iso/" -type f)
echo "[+] Generated install iso image to: $IMG"

else
    help
fi


