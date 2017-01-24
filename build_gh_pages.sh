#!/bin/bash
pub get
pub build
rm -rf ~/pic-edit-online-gh-pages
mkdir ~/pic-edit-online-gh-pages
cp -R build/ ~/pic-edit-online-gh-pages
cp web/main.dart ~/pic-edit-online-gh-pages/build/web/
git checkout gh-pages
rm -rf *
cp -R ~/pic-edit-online-gh-pages/build/ ./build/
