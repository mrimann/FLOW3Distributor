#!/bin/bash
#
# This script is licensed under the MIT license.
#
# Copyright (c) 2011-2012 Mario Rimann <mario@rimann.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
# OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#


# ask for the name of the distribution to create (target folder name)
echo "How will your distribution be named (this will be the name of the directory containing the new Distribution):"
read targetName

if [ -z ${targetName} ]; then
	echo "Oops, you did not specify a directory name, we won't get happy that way... Please try again."
	exit 1
fi

# Check if the target directory exists already and exit if it does
if [[ -d ${targetName} ]]; then
	echo "Ooops, the directory \"${targetName}\" seems to exist already!"
	exit 2
fi

# If we got that far, create the target directory
mkdir ${targetName}


# Check if the directory for (temporarily) cloning the FLOW3 Base Distribution exists already
if [[ -d FLOW3_BaseDistribution ]]; then
	echo "Ooops, the directory \"FLOW3_BaseDistribution\" seems to exist already - we can't clone into that directory then!"
	exit 3
fi


echo "OK, seems we have a GO. Let's go Jolly Jumper"


# init the new distribution
cd ${targetName}
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

mv FLOW3_BaseDistribution/Web ${targetName}/
mv FLOW3_BaseDistribution/flow3 ${targetName}/
mv FLOW3_BaseDistribution/flow3.bat ${targetName}/
mv FLOW3_BaseDistribution/Configuration ${targetName}/
rm -rf FLOW3_BaseDistribution


# let's move on to the new distribution's directory and pimp it a bit
echo "Now going to pimp the new distribution a bit..."
cd ${targetName}


# create our own Routes.yaml file
echo "Now creating a custom Routes.yaml file"
cat > Configuration/Routes.yaml << EOF
##
# FLOW3 subroutes
#

-
  name: 'FLOW3'
  uriPattern: '<FLOW3Subroutes>'
  defaults:
    '@format': 'html'
  subRoutes:
    FLOW3Subroutes:
      package: TYPO3.FLOW3
EOF

# ask whether the Admin package should be integrated
echo
echo
while true; do
	read -p "Do you want the Admin Package to be integrated and activated? (y/n)" yn
	case $yn in
		[Yy]* ) git submodule add git://github.com/mneuhaus/FLOW3-Admin.git Packages/Application/Admin
				./flow3 package:activate Admin
				mv Configuration/Routes.yaml Configuration/Routes_orig.yaml
				cat > Configuration/Routes.yaml << EOF
##
# Admin package subroutes
#

-
  name: 'Authentication Actions'
  uriPattern: 'authentication(/{@action})'
  appendExceedingArguments: true
  defaults:
    '@controller': 'Login'
    '@action': 'index'

-
  name: 'Logout'
  uriPattern: 'logout'
  defaults:
    '@action': 'logout'
    '@package': 'Admin'
    '@controller': 'Login'
    '@format': 'html'

-
  name: 'Admin actions'
  uriPattern: '{@action}'
  defaults:
    '@action': 'index'
    '@controller': 'Standard'
    '@format': 'html'
    
-
  name: 'Admin actions'
  uriPattern: '{@action}/{being}'
  appendExceedingArguments: true
  defaults:
    '@action': 'index'
    '@controller': 'Standard'
    '@format': 'html'

EOF
				cat Configuration/Routes_orig.yaml >> Configuration/Routes.yaml
				rm -f Configuration/Routes_orig.yaml
				echo
				echo
				echo "Do not forget to run ./flow3 doctrine:migrate and to flush the FLOW3 caches!"
				echo
				break;;
		[Nn]* ) echo "OK, no Admin Package for you - let's finish with the other stuff..."
				echo
				break;;
		* ) echo "Please answer yes or no.";;
	esac
done


# ask whether an own package shall be included
echo
echo
echo "Now we're almost done, but we could add a package if you'd like...?"
echo "Note: The package to be included needs to be available as a Git repo that we can add as a submodule."
while true; do
	read -p "Do you want to package an other package into this distribution? (y/n)" yn
	case $yn in
		[Yy]* ) read -p "Please enter the package Name including the VendorPrefix (e.g. \"Acme.Example\"): " packageName
				read -p "Please enter the URL to the Git repository of this package: " packageRepoUrl
				git submodule add ${packageRepoUrl} Packages/Application/${packageName}
				./flow3 package:activate ${packageName}
				echo
				echo
				echo "Do not forget to run ./flow3 doctrine:migrate and to flush the FLOW3 caches!"
				echo
				break;;
		[Nn]* ) echo "OK, no additional Package for you - let's finish with the other stuff..."
				echo
				break;;
		* ) echo "Please answer yes or no.";;
	esac
done






# ignore certain files from being versioned by Git
touch .gitignore
cat > .gitignore <<EOF
Data/Logs/
Data/Persistent/EncryptionKey
Data/Temporary/*
Web/_Resources/*
EOF


# commit all those changes as an initial commit
git add .
git commit -a -m "Setting up the initial distribution" --author "FLOW3Distributor <mario@rimann.org>"
