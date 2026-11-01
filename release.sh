#!/usr/bin/env bash

GIT_DEVELOP_BRANCH='develop'
GIT_REMOTE='upstream'

show_syntax() {
    echo "You want to release a new version"
    echo "  - current version: ${currentVersion}"
    echo "  - release version: ${releaseVersion} (which is a patch)"
    echo " "
    echo "Usage: $0 <patch|minor|major>" >&2
    exit 1
}

currentVersion=$(./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout)
releaseVersion=${currentVersion//-SNAPSHOT/}

checkGit=$(git status --porcelain | wc -l)
if [[ $checkGit != 0 ]]; then
    echo "*** check: there are uncommitted changes..."
    echo " "
    show_syntax
fi

if [ "$#" -ne 1 ]; then
    show_syntax
fi

echo "*** git: update project..."
git switch $GIT_DEVELOP_BRANCH
git fetch $GIT_REMOTE
git rebase $GIT_REMOTE/$GIT_DEVELOP_BRANCH

echo "*** use specific settings.xml"
mv ~/.m2/settings.xml ~/.m2/settings.xml.save 2> /dev/null
cp ~/.m2/personnal.settings.xml ~/.m2/settings.xml