#!/bin/bash
#
# TODO: 
# - tar and backup sliceDataInstantaneous, boundaryData
# - backup processor directories
#
set -e
restarttime=70200 # with boundaryData for finite domain sim
finishtime=86400

if [ -z "$1" ]; then
    echo 'Specify backup destination'
    exit 1
fi

curdir=`pwd`
casename=${curdir##*/}
tgtdir="$1/$casename"
if [ -d "$tgtdir" ]; then
    echo "Backup directory already exists: $tgtdir"
    echo '**********************************************'
    echo '* YOU PROBABLY WANT TO ABORT <Ctrl+C> NOW!!! *'
    echo '**********************************************'
    read -p 'Otherwise, press <enter> to continue... '
fi
mkdir -p "$tgtdir"

echo "Backing up files to $tgtdir"

rsync -aPvh runscript.* setUp README log.* \
    0.original constant system \
    $tgtdir/

# exclude sliceDataInstantaneous, boundaryData
rsync -aPvh \
    --include='postProcessing' \
    --include='postProcessing/virtualmet' \
    --include='postProcessing/virtualmet/**' \
    --include='postProcessing/surfaceProbe' \
    --include='postProcessing/surfaceProbe/**' \
    --include='postProcessing/sourceHistory' \
    --include='postProcessing/sourceHistory/**' \
    --include='postProcessing/planarAveraging' \
    --include='postProcessing/planarAveraging/**' \
    --exclude='*' \
    ./ $tgtdir/

# tar or reconstruct this instead...
#rsync -aPvh \
#    --include='processor*' \
#    --include='processor*/constant' \
#    --include='processor*/constant/**' \
#    --include="processor*/$restarttime" \
#    --include="processor*/$restarttime/**" \
#    --include="processor*/$finishtime" \
#    --include="processor*/$finishtime/**" \
#    --exclude='*' \
#    ./ $tgtdir/
