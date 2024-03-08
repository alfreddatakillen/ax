#!/bin/bash
qemu-system-x86_64 --cdrom build/ax-amd64.hybrid.iso --enable-kvm --enable-kvm -m 8G
