#!/bin/bash

# Check if the target directory exists already and exit if it does
if [[ -d Distribution ]]; then
	echo "Ooops, the directory \"Distribution\" seems to exist already!"
	exit 1
fi

# If we got that far, create the target directory
mkdir Distribution


# Check if the directory for (temporarily) cloning the FLOW3 Base Distribution exists already
if [[ -d FLOW3_BaseDistribution ]]; then
	echo "Ooops, the directory \"FLOW3_BaseDistribution\" seems to exist already - we can't clone into that directory then!"
	exit 2
fi


echo "OK, seems we have a GO. Let's go Jolly Jumper"

# init the new distribution
cd Distribution
git init


# hook in all the needed submodules
git submodule add git://git.typo3.org/FLOW3/Packages/TYPO3.FLOW3.git Packages/Framework/TYPO3.FLOW3
git submodule add git://git.typo3.org/FLOW3/Packages/TYPO3.Fluid.git Packages/Framework/TYPO3.Fluid
git submodule add git://git.typo3.org/FLOW3/Packages/TYPO3.Kickstart.git Packages/Framework/TYPO3.Kickstart
git submodule add git://git.typo3.org/FLOW3/Packages/TYPO3.Party.git Packages/Framework/TYPO3.Party
git submodule add git://git.typo3.org/FLOW3/Packages/Doctrine.ORM.git Packages/Framework/Doctrine.ORM
git submodule add git://git.typo3.org/FLOW3/Packages/Doctrine.Common.git Packages/Framework/Doctrine.Common
git submodule add git://git.typo3.org/FLOW3/Packages/Doctrine.DBAL.git Packages/Framework/Doctrine.DBAL
git submodule add git://git.typo3.org/FLOW3/Packages/Symfony.Component.Yaml.git Packages/Framework/Symfony.Component.Yaml
git submodule add git://git.typo3.org/FLOW3/BuildEssentials.git Build/Common


# add the needed base files from the FLOW3 base distribution
cd ../
git clone git://git.typo3.org/FLOW3/Distributions/Base.git FLOW3_BaseDistribution

mv FLOW3_BaseDistribution/Web Distribution/
mv FLOW3_BaseDistribution/flow3 Distribution/
mv FLOW3_BaseDistribution/flow3.bat Distribution/
mv FLOW3_BaseDistribution/Configuration Distribution/
rm -rf FLOW3_BaseDistribution


# commit all those changes as an initial commit
cd Distribution
git add .
git commit -a -m "Setting up the initial distribution" --author "FLOW3Distributor <mario@rimann.org>"
