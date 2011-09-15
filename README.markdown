# Pre-Requirements

* Host OS: Ubuntu 11.04. (Because the script tested only with Ubuntu 11.04).
* Access to the internet (But if you can use your local ubuntu mirror, no internet access will need. Again, tested only with official mirror accessible via the internet).
* root access (or sudo).

# How to configure ubuntukickstart.sh script

The right and the only way to configure the script is the setting of environment variables:

* **LOG\_FILE** is used to specify the location of log file. Defaults to **ubuntukickstart.log**.
* **HTTP\_ROOT** is used to specify the location of host http root directory. Defaults to **/var/www**.
* **KICKSTART\_HTTP\_PATH** is used to specify the URL of kickstart file. Defaults to **http://$BRIDGE_IP/ks.cfg**.
* **CLOUDPIPECONF\_PATH** is used to specify the location of **cloudpipeconf.sh**. Defaults to **cloudpipeconf.sh**.
* **UBUNTU\_MIRROR\_URL** is used to specify the URL of Ubuntu mirror. Defaults to <http://archive.ubuntu.com/ubuntu>.
* **NETBOOT\_IMG** is used to specify the URL of ubuntu server netboot tarball. Defaults to <http://archive.ubuntu.com/ubuntu/dists/natty/main/installer-i386/current/images/netboot/netboot.tar.gz>.
* **NETWORK\_NAME** is used to specify the name of virtual libvirt network. Defaults to **ubuntu-pxe**.
* **REAL\_IFACE** is used to specify the real host (not VM) network interface with internet access. Defaults to **eth0**.
* **BRIDGE\_IFACE** is used to specify the name of virtual bridge interface. Defaults to **vbr27**.
* **BRIDGE\_IP** is used to specify the IP address of virtual bridge interface. Defaults to **192.168.119.1**.
* **BRIDGE\_NETMASK** is used to specify the network mask of virtual bridge interface. Defaults to **255.255.255.0**.
* **DHCP\_START** is used to specify the first network address of DHCP range for virtual network. Defaults to **192.168.119.2**.
* **DHCP\_END** is used to specify the last network address of DHCP range for virtual network. Defaults to **192.168.119.254**.
* **TFTPBOOT\_DIR** is used to specify the root directory of TFTP server. Defaults to **/tftpboot**.
* **BOOTP\_FILE** is used to specify the file of boot image. Defaults to **pxelinux.0**.
* **ROOT\_PASSWD\_FILE** is used to specify the file where VM root password will be stored. Defaults to **rootpasswd.txt**.
* **ROOT\_PASSWORD** is used to specify the root password. Defaults to random generated password by **makepasswd** utility. Then this password will be stored in **ROOT\_PASSWD\_FILE**.
* **VM\_MAC** is used to specify MAC of the VM. Defaults to **00:16:3e:77:e2:ed**.
* **VM\_IP** is used to specify IP of the VM. Defaults to **192.168.119.10**.
* **VM\_NAME** is used to specify the VM name. Defaults to **NewMach**.
* **VM\_RAM** is used to specify the total amount of VM RAM in MB. Defaults to **384**.
* **VM\_DISK\_SIZE\_GB** is used to specify the size of the hdd image in GB. Defaults to **1**.
* **VM\_DISK\_PATH** is used to specify the path to the hdd image. Defaults to **new\_cloudpipe\_image.img**.

# Creating cloudpipe image
* Get all needed scripts from repo:
    * cloudpipeconf.sh
    * ssh.sh
    * ubuntukickstart.sh

* Run **ubuntukickstart.sh** under root privilegies. Use environment variables to configure it, if necessary. Default configuration is valid and fully workable.
* Wait for an end of ubuntu server installation.
* Verify that the VM is not running like this:

    \# virsh list --all

  You will see the status of the VM named **$VM_NAME**. Make sure that it is in the **shut off** state.
* Check the log file for any failed operations.
* Then upload the VM hdd image into OpenStack. Don't forget about root password.

# Theory of operation of ubuntukickstart.sh
1. Install all needed packages.
1. Configure virtual network for the VM.
1. Create virtual network.
1. Make TFTP root directory.
1. Download Ubuntu Server 11.04 netboot tarball.
1. Extract it into TFTP root directory.
1. Edit some files in TFTP root directory (to switch on automatic install using **kickstart**).
1. Get root password for the VM.
1. Edit kickstart config file and copy it into http server root directory.
1. Copy cloudpipeconf.sh file into http server root directory, too.
1. Start a new VM with automated ubuntu server install.
1. Wait for an end of it installation, then shutdown it.
1. If everything goes right the cloudpipe image will be ready for usage. Root password will be stored at **rootpasswd.txt** by default or at path provided by **$ROOT\_PASSWD\_FILE**.

# Known issues

* If you already have **rootpasswd.txt** file or another wich is specified by **$ROOT\_PASSWD\_FILE**, the script will **overwrite** it. So, you can lost root password stored in this file before.
