What's this all about?
----------------------

	Please note: With the switch to Composer that was done while working on TYPO3 Flow v2.0, I guess this
	Script is not needed anymore at all - just use Composer to kickstrap your distribution and require
	the stuff needed in your distribution.

	But of course, you can continue to use this script in case you want to easily keep track of the
	changes to the Base-Distribution offered on git.typo3.org

The goal of this small bash script is to simplify the process of creating a new base distribution for a new project. If you're "just" creating a package for FLOW3 that will be part of an existing FLOW3 installation, you probably won't need this. It is intented for situations where you want to start a project that can be shipped out of the box by delivering a full blown distribution that contains all the needed components like the FLOW3 Framework, Fluid templating engine and some basic config files.

**Attention:** Of course you need to "add life" to this new empty distribution by adding your package(s) and changing the config files to your need. It's more like a kickstarter, not a wonder-machine.


How to use?
-----------
Basically you just need to checkout the "Distributor" Package and to run the shell script::

    git clone git@github.com:mrimann/FLOW3Distributor.git FLOW3Distributor
    cd FLOW3Distributor
    ./FLOW3Distributor.sh

This will create the following directory structure::

    FLOW3Distributor
        Distribution		<-- contains your new empty distribution (with your chosen name)
        TYPO3Distributor.sh
        README.rst

During the run of the script, the basically needed submodules like FLOW3 itself are being added as Git submodules automagically. Your're getting asked about adding further FLOW3-Packages either directly from git.typo3.org - or from any other Git repository.

How to stay up to date?
.......................
The script now knows two different operation modes how to create your new distribution:

Create a virgin distribution
	This will create a distribution containing all the required packages as Git submodules and the history of the generated repository starts with an initial commit.
	In case the Core Developers of FLOW3 publish changes to the FLOW3 Base-Distribution hosted on git.typo3.org, these changes are **not** directly fetchable into the new repository.

Create a linked clone distribution
	This will create a repository that has the FLOW3 Base-Distribution's repository at git.typo3.org as a separate remote called "typo3". The history of the newly created Distribution repository will contain all the commits that have been in the repository at the time of cloning.
	The profit of doing so is, that you will later on be easily able to fetch and merge changes from the Core Developers of FLOW3 into your own Distribution repository and keep track of all the changes that they made - and you're even able to do your own changes on top of their changes and keep track of them, too. Yes, thanks to Git this is possible :-)

The script asks you which way you want to go - just answer accordingly.


Publishing your new distribution is easy!
.........................................
Just move your Distribution directory to wherever you need. It's a full blown Git repository that already contains the first commit and all the needed submodules.


Feedback?
---------
Please yes - just send it to mario@rimann.org and let's see what I can make out of it. Of course, nice "thank you" mails are appreciated most :-)


Found a bug or want an additional feature?
------------------------------------------
Don't worry, just open an issue on GitHub (https://github.com/mrimann/FLOW3Distributor/issues) or even better: Fix it and contribute it back to the project. You can fork the sourcecode from the Git repository and send me a pull request as soon as you've finished.


Contributors
------------
Thanks to the following persons for contributing ideas and/or sourcecode to this project - you're very welcome!

- Jacob Floyd (https://github.com/cognifloyd)