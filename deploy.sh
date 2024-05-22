#! /bin/bash
set -eu

rm -rf ./deploy
mkdir -p deploy

if [[ ! -v VERSION ]]; then
    echo "** ERROR ** "VERSION" needs to be set!"
    echo "Use Hyperion's current version on first deployment of that version (i.e. VERSION=0.16.7)"
    echo "Bump the version and append a pre-release number if adding edits after deployment (i.e. VERSION=0.16.8-1)"
    exit 1
fi
cp helios.js helios.d.ts helios-internal.d.ts LICENSE README.md package.json deploy/

cd ./deploy

jq '.name="@koralabs/helios"' package.json > package.tmp && mv package.tmp package.json
jq --arg version "$VERSION" '.version=$version' package.json > package.tmp && mv package.tmp package.json
sed -i -e "s/\(Version: \+\)[0-9]\{1,2\}.[0-9]\{1,2\}.[0-9]\{1,2\}/\1$VERSION/g" ./helios.js
#npm publish --@koralabs:registry='https://npm.pkg.github.com'
npm publish --access public --ignore-scripts --@koralabs:registry='https://registry.npmjs.org'

cd ..