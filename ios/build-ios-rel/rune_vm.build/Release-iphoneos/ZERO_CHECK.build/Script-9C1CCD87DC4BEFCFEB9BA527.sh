#!/bin/sh
set -e
if test "$CONFIGURATION" = "Debug"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  make -f /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "Release"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  make -f /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "MinSizeRel"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  make -f /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "RelWithDebInfo"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  make -f /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel/CMakeScripts/ReRunCMake.make
fi

