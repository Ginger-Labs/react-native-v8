#!/bin/bash -e
source $(dirname $0)/env.sh

######################################################################################
# [0] Patch React Native source
######################################################################################

rm -rf $BUILD_DIR
if [ $LOCAL_ONLY = true ] ; then
  echo "Building locally isn't supported yet."
else
  if [ $RN_PATH ] ; then	
    echo copying $RN_PATH into $BUILD_DIR
    #git clone --depth=1 --branch ${RN_VERSION} https://github.com/Ginger-Labs/react-native.git $BUILD_DIR
    cp -Rf $RN_PATH $BUILD_DIR
  else 
    echo "RN_PATH is not defined, please export RN_PATH first (the path to .../bagel/node_modules/react-native)"
  fi
fi

PATCHSET=(
  # Patch React Native build to support v8runtime
  "build_with_v8.patch"
)

cp -Rf $SRC_DIR/v8runtime $BUILD_DIR/ReactCommon/jsi/
cp -Rf $SRC_DIR/androidexecutor $BUILD_DIR/ReactAndroid/src/main/java/com/facebook/v8
cp -Rf $SRC_DIR/sowrapper $BUILD_DIR/ReactAndroid/src/main/jni/third-party/v8

for patch in "${PATCHSET[@]}"
do
    printf "### Patch set: $patch\n"
    patch -d $BUILD_DIR -p1 < $PATCHES_DIR/$patch
done

######################################################################################
# [1] Build
######################################################################################

#cd $BUILD_DIR
#yarn
#./gradlew :ReactAndroid:installArchives

#mkdir -p $DIST_DIR
#cd ..
#cp -Rf $BUILD_DIR/android/* $DIST_DIR
