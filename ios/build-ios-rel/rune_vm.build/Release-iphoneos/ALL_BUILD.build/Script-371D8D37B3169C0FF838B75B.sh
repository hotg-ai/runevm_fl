#!/bin/sh
set -e
if test "$CONFIGURATION" = "Debug"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  echo Build\ all\ projects
fi
if test "$CONFIGURATION" = "Release"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  echo Build\ all\ projects
fi
if test "$CONFIGURATION" = "MinSizeRel"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  echo Build\ all\ projects
fi
if test "$CONFIGURATION" = "RelWithDebInfo"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  echo Build\ all\ projects
fi

