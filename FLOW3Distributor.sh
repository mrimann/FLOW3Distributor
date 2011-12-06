#!/bin/bash

mkdir Distribution

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
#rm -rf FLOW3_BaseDistribution

cd Distribution
git add .
git commit -a -m "Setting up the initial distribution"
