# Utilityes for Firefox/Thunderbird Add-on Developers

## Building XPI packages

### Requirements

 * bash
 * sed
 * zip
 * GNU cp
 * GNU sha1sum

For Windows, you must setup [Cygwin](https://www.cygwin.com/) for these required commands and add the path to the Cygwin's `bin` directory via the envrionemnt variable `PATH`, like:

    set PATH=C:\cygwin\bin;C:\Program Files\TortoiseGit\bin;...

### How to install scripts to build XPI packages?

First, put these tools under a directory named `makexpi`, at the root of your project.
If it is a Git repository, you should add this as a submodule, like:

    $ git clone git@github.com/piroor/new-addon
    $ cd new-addon
    $ git submodule add https://github.com/piroor/makexpi.git

Next, run the script `prepare_build_scripts.sh` as:

    $ makexpi/prepare_build_scripts.sh -n "package-name-of-new-addon"

Even if you forget to specify the `-n` option, the script will ask it to you with a prompt.
Then you'll get three new files:

 * `Makefile`
 * `make.bat`, a batchfile for Windows with Cygwin.
 * `make.sh`, a bash script for Windows with Cygwin.

### How to build XPIs with GNU make?

You'll just have to type `make` to build XPI package, like:

    $ make
    ...
    ...
    ...
    $ ls *.xpi
    package-name-of-new-addon.xpi package-name-of-new-addon_noupdate.xpi

The file with a suffix `_noupdate` is a sanitized version for the Mozilla Add-ons.
Even if you specify your custom `updateURL` and `updateKEY` in your `install.rdf`, they are automatically sanitized.

For Windows, launch the batch file `make.bat` by double click.

### How to sign to XPIs? / How to upload built XPI to Mozilla Add-ons website?

First, you must generate an API key.
See the entry: https://blog.mozilla.org/addons/2015/11/20/signing-api-now-available/

For example, if you get the result:

 * JWT issuer: `user:xxxxxx:xxx`
 * JWT secret: `yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy`

then set them to environment variables `JWT_KEY` and `JWT_SECRET` and run `make signed`.

    $ export JWT_KEY=user:xxxxxx:xxx
    $ export JWT_SECRET=yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
    $ make signed

If your XPI package is automatically signed, it will be downloaded to the current directory.
However, if it requires manual review by AMO editors, you'll have to download it by hand after preliminary or full review.

You can use this command to upload new version for your public (listed) addon also.
Note that a new version uploaded by this command will have no version description.
After you upload a new version, you'll have to log in to the developer hub and complete the version manually.
