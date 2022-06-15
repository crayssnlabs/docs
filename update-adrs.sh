#! /usr/bin/env bash

# git clone --depth 1 git@github.com:shopware/platform.git

rm -r ./adr
#rm -r ./.gitbook/assets/adr
cp -r ./platform/adr ./
# rm -rf ./platform

summary=$(find adr -type f -name '*md' -not -name '_*' | tr '/' ' ' | awk -f ./generate-summary.awk)

sed -i '/## Architecture decision record/,$d' ./SUMMARY.md
echo "" >> ./SUMMARY.md
echo "## Architecture decision record" >> ./SUMMARY.md
echo "" >> ./SUMMARY.md
echo "$summary" >> ./SUMMARY.md

mkdir -p ./.gitbook/assets/adr
cp -r adr/assets/* .gitbook/assets/adr/ 
find adr -type f -name '*md' -not -name '_*' -exec sed -i 's#(\./assets#(../../.gitbook/assets/adr#' {} \;

find adr/ -type d -exec touch '{}'/README.md \;
