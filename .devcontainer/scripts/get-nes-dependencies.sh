#!/usr/bin/env bash

set -eu

path_to_workspace="$(dirname $0)/../.."

curl --silent -L https://github.com/cc65/cc65/archive/refs/heads/master.zip -o /tmp/cc65.zip

unzip -q /tmp/cc65.zip -d /tmp/cc65/

mkdir -p "${path_to_workspace}/macros"
mv -n /tmp/cc65/cc65-master/libsrc/nes/* "${path_to_workspace}/macros"

mkdir -p "${path_to_workspace}/include"
mv -n /tmp/cc65/cc65-master/asminc/nes.inc "${path_to_workspace}/include"

rm -rf /tmp/cc65
