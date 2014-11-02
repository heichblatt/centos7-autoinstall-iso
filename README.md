# Automatically installing ISOs for CentOS 7

We use modified CentOS installation media to automatically deploy server VMs.
Most tasks are implemented as Makefile targets.
Most configuration steps are defined in kickstart.cfg and explained in the comments there.

## Targets

  * clean: remove build directory
  * prerequisites: check that all necessary software is installed
  * inputiso: download upstream ISO if necessary
  * config: copy configuration templates to config files
  * test: build in Docker

## Generate a new ISO

  * adjust the variables at the beginning of the Makefile
  * `make config` to create your config, customize the files
  * place any scripts to be placed in `/root` in the installed system into the `scripts` directory
  * `make`

## Default Credentials

The following account is configured during installation:

 * username: admin
 * password: changeme

The password should be changed during the firstrun.sh run.

## After the Installation

Once the installer has finished and rebooted into the system, login as admin, then:

    sudo -i      # become root
    cd
    # call your scripts

## Notes

 * If you cancelled a run, you can clean up with `make clean`.
 * The Git commit hash is inserted into the isolinux boot menu head line.
 * Any output of the installation is written to `/root/*log` in the installed system.

## References

 * [Red Hat Documentation on Kickstart](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Installation_Guide/sect-kickstart-syntax.html)
 * ["Testing Red Hat Enterprise Linux 7 and CentOS 7 (preview)"](https://sig-io.nl/?p=372): Useful blogpost with examples
 * [Building a custom CentOS 7 kickstart disc](http://smorgasbork.com/component/content/article/35-linux/153-building-a-custom-centos-7-kickstart-disc-part-3): was used to create the script
