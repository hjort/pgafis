#!/bin/bash

# http://biometrics.idealtest.org/findDownloadDbByMode.do?mode=Fingerprint
# http://biometrics.idealtest.org/dbDetailForUser.do?id=7

rm -rf images
mkdir images

for a in CASIA*.zip; do unzip "$a" -d images; done

exit 0

