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
echo
echo
echo "What should your distribution be named (this will be the name of the directory"
echo "containing the new Distribution):"
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


# let's check whether we shall clone recursive or if we shall use the "old" mechanism of really creating
# our own distribution by adding the submodules "by hand"
echo
echo "Your distribution can either be independent or linked to the original Base Distribution from"
echo "git.typo3.org - that's up to you and whether you'll really need this additional feature that"
echo "Git offers."
echo
echo "yes = your Distribution will get an additional remote called \"typo3\" from which you can then"
echo "      pull updates in the Base-Distribution of FLOW3 but you can also push/pull from your own"
echo "      repository which is the remote called \"origin\"."
echo "no  = your Distribution won't be linked to the original Base Distribution from git.typo3.org"
echo "      and you'll have just one Git remote called \"origin\" to push/pull to/from."
echo
while true; do
	read -p "Do you want to use Base.git from typo3.org as a typo3 origin? (if you don't know, just say no) (y/n) " yn
	case $yn in
		[Yy]* ) doRecursiveClone=true
				break;;
		[Nn]* ) doRecursiveClone=false
				break;;
		* ) echo "Please answer yes or no.";;
	esac
done
echo


# Check if the directory for (temporarily) cloning the FLOW3 Base Distribution exists already
if ! $doRecursiveClone; then
	if [[ -d FLOW3_BaseDistribution ]]; then
		echo "Ooops, the directory \"FLOW3_BaseDistribution\" seems to exist already - we can't clone into that directory then!"
		exit 3
	fi
fi

# Adds package to the package stack of packages that need to be included. Once included, they'll be 'pop'ed off.
function pkg_push {
	pkg_arr=("${pkg_arr[@]}" "$1")
}

# Adds the url for a given package to the stack
function pkg_url_push {
	pkg_url_arr=("${pkg_url_arr[@]}" "$1")
}

# Asks for Package Name
function promptForPkgName {
	read -p "Please enter the package Name including the VendorPrefix (e.g. \"Acme.Example\"): " packageName
	pkg_push $packageName
}

echo
echo "Besides the basic FLOW3 packages, you might want to include other packages in this distribution."
echo
#admin package prompt
while true; do
	read -p "Do you want the Admin Package to be integrated and activated? (y/n) " yn
	case $yn in
		[Yy]* ) pkg_admin=true
				break;;
		[Nn]* ) echo "OK, no Admin Package for you."
				pkg_admin=false
				break;;
		* ) echo "Please answer yes or no.";;
	esac
done

# ask about including another package in the distribution
echo
echo
echo "There are a lot of packages that we can include if you'd like."
echo "Note: Each included package needs to be available as a Git repo that we can add as a submodule."
echo "For packages that are available on git.typo3.org, you only need the Package name - but you can"
echo "also add every any Git repositories that contain a valid FLOW3 Package."
echo
echo

# ask about packages from git.typo3.org
first=true
while true; do
	#Note: we can't use ./flow3 package:import because we want to include the package
	#in the distribution, and package:import doesn't add it as a git submodule.
	if $first; then
		read -p "Do you want to include a package from git.typo3.org in this distribution? (y/n) " yn
		first=false
	else
		read -p "Do you want to include another package from git.typo3.org? (y/n) " yn
	fi
	case $yn in
		[Yy]* ) promptForPkgName
				pkg_url_push "git://git.typo3.org/FLOW3/Packages/${packageName}"
				;;
				# No break, so that we can ask for multiple packages
		[Nn]* ) echo "OK, no more TYPO3 packages."
				echo
				echo "Perhaps there are packages in a different git repository that you want to include...?"
				echo
				break;;
		* ) echo "Please answer yes or no.";;
	esac
done

# ask for any other package to include
while true; do
	echo
	read -p "Do you want to include any other packages in this distribution? (y/n) " yn
	case $yn in
		[Yy]* ) promptForPkgName
				read -p "Please enter the URL to the Git repository of this package: " packageRepoUrl
				pkg_url_push $packageRepoUrl
				;;
		[Nn]* ) echo "OK, no more packages for you - let's finish with the other stuff..."
				echo
				break;;
		* ) echo "Please answer yes or no.";;
	esac
done

echo
echo "OK, seems we have a GO. Let's go Jolly Jumper"
echo


# init the new distribution
cd ${targetName}
if $doRecursiveClone; then
	git clone --recursive -o typo3 git://git.typo3.org/FLOW3/Distributions/Base.git ${targetName}
	git config --unset branch.master.remote
	cd ${targetName}/
else
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
	cd ${targetName}
	
	# create our own Routes.yaml file
	echo "Now creating a custom Routes.yaml file"
	cat > Configuration/Routes.yaml <<EOF
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

fi

# ignore certain files from being versioned by Git
touch .gitignore
cat > .gitignore <<EOF
Build/Archives/
Build/Reports/
Build/Temporary/
Data/Logs/
Data/Persistent/EncryptionKey
Data/Temporary/*
Packages/.Shortcuts/
Web/_Resources/*
EOF


# Add Base.git as remote
#git remote add typo3 git://git.typo3.org/FLOW3/Distributions/Base.git
#git pull typo3 master

# TODO Make it ask for and add a custom remote origin url:
#git remote add <wherever this repo is supposed to go> origin
# And then at the end of this script, push the resulting distro:
#git push origin

# TODO make it checkout a particular tag like FLOW3_1.0.4 or something.



# include the Admin package if it was requested before
if $pkg_admin; then
	git submodule add git://github.com/mneuhaus/FLOW3-Admin.git Packages/Application/Admin
	./flow3 package:activate Admin
	mv Configuration/Routes.yaml Configuration/Routes_orig.yaml
	cat > Configuration/Routes.yaml <<EOF
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
else
	echo "Skipping the Admin Package - let's finish with the other stuff..."
fi


# Includes each Package as a submodule of the Distribution and activates it
pkg_count=${#pkg_arr[@]}
for (( i=0; i<${pkg_count}; i++ )); do
	git submodule add ${pkg_url_arr[$i]} Packages/Application/${pkg_arr[$i]}
	./flow3 package:activate ${pkg_arr[$i]} 
done



# commit all those changes as an initial commit
git add .
git commit -a -m "Setting up the initial distribution" --author "FLOW3Distributor <mario@rimann.org>"

echo
echo
if $pkg_admin || [[ $pkg_count > 0 ]]; then
	echo "Do not forget to run ./flow3 doctrine:migrate and to flush the FLOW3 caches!"
	echo
fi
echo "If you'll be hosting this distro on github (or similar) be sure to add an origin and push to it:"
echo "   git remote add origin <url where this repo is supposed to go>"
echo "   git config branch.master.remote origin"
echo "   git push -u origin master"
