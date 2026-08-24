#!/bin/sh
set -eu

OVMF_REPOSITORY=https://github.com/AMDESE/ovmf.git
OVMF_COMMIT=fbe0805b2091393406952e84724188f8c1941837
SOURCE_DATE_EPOCH=1740099036
REPOSITORY_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_DIR=/tmp/base-ovmf-source
test ! -e "$SOURCE_DIR"
mkdir "$SOURCE_DIR"
trap 'rm -rf "$SOURCE_DIR"' EXIT HUP INT TERM

git -C "$SOURCE_DIR" init -q
git -C "$SOURCE_DIR" remote add origin "$OVMF_REPOSITORY"
git -C "$SOURCE_DIR" fetch -q --depth 1 origin "$OVMF_COMMIT"
git -C "$SOURCE_DIR" checkout -q --detach FETCH_HEAD
test "$(git -C "$SOURCE_DIR" rev-parse HEAD)" = "$OVMF_COMMIT"
git -C "$SOURCE_DIR" submodule update --init --jobs "${JOBS:-8}"

export SOURCE_DATE_EPOCH
export PYTHON_COMMAND=python3
make -C "$SOURCE_DIR/BaseTools" clean
make -C "$SOURCE_DIR/BaseTools" -j"${JOBS:-8}"
cd "$SOURCE_DIR"
set +u
. ./edksetup.sh --reconfig
set -u
: > OvmfPkg/AmdSev/Grub/grub.efi
build -q --cmd-len=64436 -DDEBUG_ON_SERIAL_PORT=TRUE -n "${JOBS:-8}" -t GCC -a X64 -p OvmfPkg/AmdSev/AmdSevX64.dsc -b RELEASE
install -Dm0644 Build/AmdSev/RELEASE_GCC/FV/OVMF.fd "$REPOSITORY_DIR/dist/OVMF.fd"
