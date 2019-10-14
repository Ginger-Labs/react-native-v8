#!/bin/bash -e
source $(dirname $0)/env.sh

######################################################################################
# [0] Patch React Native source
######################################################################################

rm -rf $BUILD_DIR

if [ $LOCAL_ONLY = true ] ; then
  echo "Building locally isn't supported yet."
else
  if [ $RN_VERSION = true ] ; then	
    echo clonning v: $RN_VERSION into $BUILD_DIR
    git clone --depth=1 --branch ${RN_VERSION} https://github.com/Ginger-Labs/react-native.git $BUILD_DIR
  else 
    echo "RN_VERSION is not defined, please export RN_VERSION first (the version tag)"
  fi
fi

PATCHSET=(
  # Patch React Native build to support v8runtime
  "build_with_v8.patch"
)

cp -Rf $ROOT_DIR/v8runtime $BUILD_DIR/ReactCommon/jsi/

for patch in "${PATCHSET[@]}"
do
    printf "### Patch set: $patch\n"
    patch -d $BUILD_DIR -p1 < $PATCHES_DIR/$patch
done

######################################################################################
# [1] Build
######################################################################################

cd $BUILD_DIR
yarn
./gradlew :ReactAndroid:installArchives

mkdir -p $DIST_DIR
cp -Rf $BUILD_DIR/android/* $DIST_DIR
