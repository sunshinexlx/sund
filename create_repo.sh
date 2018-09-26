#!/bin/bash
cd /shell
cat >>local.repo <<eof
[local]
name=localdik
baseurl=file:///mnt
enabled=1
gpgcheck=0
eof
