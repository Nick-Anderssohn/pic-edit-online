#!/bin/bash
pub get
pub build
rm -rf ~/pic-edit-online-gh-pages/
cp -R build/ ~/pic-edit-online-gh-pages
cp web/main.dart ~/pic-edit-online-gh-pages/bulid/web/
git checkout gh-pages
cp -R ~/pic-edit-online-gh-pages/build/ .
