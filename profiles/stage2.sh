#!/bin/sh

set -eu

rootdir="$1"

sudo systemd-nspawn -D $rootdir bash -c "(useradd -m -g users deepin || true) && (usermod -a -G sudo deepin || true)"

sudo systemd-nspawn -D $rootdir bash -c "chsh -s /bin/bash deepin || true"

sudo systemd-nspawn -D $rootdir bash -c "(echo root:deepin | chpasswd) || true"
sudo systemd-nspawn -D $rootdir bash -c "(echo deepin:deepin | chpasswd) || true"

