#!/bin/bash

# for security, prepend this to the public key stuck on the ESM
# under ~arcsight/.ssh/authorized_keys
#
# command="/usr/local/bin/rsync-static --server --sender -qlogDtprze.iLsf --remove-source-files . /home/arcsight/arcsight/Manager/archive/exports/"
#
# ... ex :
# command="/usr/local/bin/rsync-static --server --sender -qlogDtprze.iLsf --remove-source-files . /home/arcsight/arcsight/Manager/archive/exports/" ssh-dsa ABBAFEED== RT to ArcSight rsync pull

SSH_KEY="/opt/rt3/.ssh/rt_to_arcsight_esm"
ARCSIGHT="arcsight@esm.arcsight.example.com"
XML_PATH=/opt/rt3/var/arcsight/exports

rsync --rsync-path="/usr/local/bin/rsync-static" -Paqz --remove-source-files -e "ssh -i $SSH_KEY" $ARCSIGHT:/home/arcsight/Manager/archive/exports/* $XML_PATH

