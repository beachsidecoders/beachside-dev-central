# VirtualBox - OS X - Ubuntu Dev Environment

The environment consists of

* A NAT network from which a VM will gain internet access.
* A host-only network from which a VM will use to communicate directly with the host mac OS X computer.
* An ubuntu 11.10 64-bit based vm from which other can be cloned with the option of using differential disk image to reduce hard disk footprint.

## VirtualBox Setup

* Go to https://www.virtualbox.org website, download, and install VirtualBox including the VirtualBox Extension Pack

### NAT Network

* The NAT Network is installed by default and no setup is necessary

### Host-only network

To setup the host-only network

* Go to the VirtualBox Menu, and choose Preferences.
* Expand the Network tab by clicking on the Network icon at the top
* Click on the + network icon on the right of the list box to create a new host-only network
* Select the newly created network, and click on the screw driver icon. If this is the first network, it will be named vboxnet0.
* In the Adapter tab page, config the ip4 info as
    * IPv4 Address - 192.168.56.1
    * IPv4 Network Mask - 255.255.255.0
    * IPv6 Address: <Blank>
    * IPv6 Network Mask Length: 0
* In the DHCP Server tab page, config as
    * Check the Enable Server
    * Server Address: 192.168.56.1
    * Server Mask: 255.255.255.0
    * Lower Address Bound: 192.168.56.200
    * Upper Address Bound: 192.168.56.254
* This guide uses the vboxnet0 host-only network and the subnet 192.168.56.0/24. One can use a different vboxnet/subnet as long as the network settings are set consistently.

### Base Ubuntu11.10 VM

* Download ubuntu11.10 iso (`ubuntu-11.10-server-amd64.iso`).
* In VirtualBox, click on the new icon, and fill in the name and os as
    * Name: ubuntu1110x64
    * Type: Linux
    * Version: Ubuntu (64 bit)
* In Memory size, leave default as 512
* In Hard drive, select Create a virtual hard drive now
* In Hard drive type, select VDI (VirtualBox Disk Image)
* In Storage on physical hard drive, select Dynamically allocated
* In File location and size, select 8 GB which should be good for the base and most development install. This will create the VM
* In VirtualBox, select the ubuntu1110x64 VM, and click on the Settings icon. Go to the Storage tab, select the CD ROM icon under the Storage Tree list. On the right of the list, click on the disc icon and select the ubuntu iso. Click on the network icon and verify that Adapter 1 is the only active adapter, and it is attached to the NAT network. Under advance, select Paravirtualized Network (virtio-net). Okay everything.
* In VirtualBox, select the ubuntu1110x64 VM, and click on the start icon.
* Install Ubuntu:
    * Language:English, Country:United States, Detect keyboard:No, Country of origin for the keyboard: English (US), Keyboard layout: English (US)
    * DHCP Network, Host name: servername.domain.tld
    * Configure the clock: Yes to Time zone - America/Los_Angeles
    * Partition disks : Guided - use entire disk and set up LVM
    * Write the changes to disks and configure LVM: Yes
    * Amount of volume group to use for guided partitioning: Leave default and choose Continue
    * Write the changes to disks : Yes
    * Enter user name, password
    * Encrypt home dir : No
    * Leave proxy blank and choose continue for no proxy
    * No automatic update
    - Choose software to install: <do not select anything>
    * Install the GRUB boot loader to the master boot record: Yes
	* Once the vm reboot, login, run `sudo apt-get update; sudo apt-get upgrade` 
    * Install Virtualbox Guest Additions

```sh
# Install dkms
sudo apt-get install dkms
sudo reboot

# Insert the VBoxGuestAdditions.iso.
# Select your vm window.
# Select from the menu, Devices | Install Guest Additions...

# Mount the CDRom and install the VBoxGuestAdditions
sudo mount /dev/cdrom /mnt
cd /mnt
sudo sh ./VBoxLinuxAdditions.run --nox11
# It is okay to get the following error
# Installing the Window System drivers ...fail!
# (Could not find the X.Org or XFree86 Window System.)

# Unmount and eject the CDRom drive
cd; sudo umount /mnt
sudo eject /dev/cdrom
```
* Shut the vm down (`sudo shutdown -h now`).    
    

### Creating a new development VM by cloning the base Ubuntu vm

* In VirtualBox, select the ubuntu1110x64 base vm, right click on the icon, and select clone.
* In new machine name, name your new development vm, and do not check Reinitialize the MAC address of all network cards.
* In clone type, select Linked clone to save disk space
* In VirtualBox, select the new clone development vm, and click on settings. Select the Network tab. Click on the Adapter 2 tab, enable it, and attach it to the Host-only Adapter with the name: vboxnet0.  In Advanced, change the Adapter type to paravirtualized network (virt-io). Okay everything, and start the VM
* Once the cloned vm starts, log in
* Rename the vm by editing the hostname file (`sudo vi /etc/hostname`). Choose a name which represent the host, is meaningul, and easy to recall the purpose of the server. Replace servername with the name you have chosen.
* Add local resolution for the new hostname by editing the host file (`sudo vi /etc/hosts`). Replace every occurrence of servername with the name you have chosen as the hostname for the server.
* Set the host-only interface by editing the interface file (`sudo vi /etc/network/interfaces`).  For this step you need to lookup or allocate from the private use range of the vboxnet0 host-only network. See IP Address Allocation in this document for pre allocated server ip. The pre allocated address should be used whenever possible to ensure compatibility. To set the host-only static ip, add the following line and replace ## with your selected host address:

```sh
# The host-only network interface
auto eth1
iface eth1 inet static
    address 192.168.56.##
    netmask 255.255.255.0
```

* Enable the host-only interface:

```sh
# Take down the eth1 interface
# Ignore the message "sudo: unable to resolve host servername..."
# and "ifdown: interface eth1 not configured"
sudo ifdown eth1
# Bring up the eth1 interface
# Ignore the message "sudo: unable to resolve host servername"
sudo ifup eth1
```

* Update the system and install openssh

```sh
sudo apt-get update; sudo apt-get upgrade; sudo apt-get install openssh-server
```

* On your host machine, go to the terminal app and ssh into your new vm using the host-only static ip that was assigned to the vm

```sh
# Replace <user> with your user name that you used to setup your ubuntu base vm,
# and ## with the host number that was assigned to the vm.
ssh <user>@192.168.56.##
```

* If everything is okay, back on your newly cloned vm, reboot (`sudo reboot`) and try ssh again to ensure that all settings stick.
* The vm is now ready for installation.
* Change console resolution (optional)


```sh
# Edit grub file
sudo vi /etc/default/grub

# uncomment the following line
GRUB_GFXMODE=640x480

# Set to new resolution (e.g. 1024x768)
GRUB_GFXMODE=1024x768

# exit editor

# update
sudo update-grub2

# reboot
sudo shutdown -r 0
```

* Mount project directory (optional)

The following procedure can be used to share a project directory on the host, identified by the path <host-project-dir> with guess virtual machine in the user home directory identify as <guest-project-dir>.  Unless the permanent instructions are followed, the effect are temporary, and when a vm is rebooted, the shared directory will no longer be accessible in the guest vm, and when he vm is shutdown, the shared directory will have to be respecified.

Sharing host directory with a guest request VirtualBox Guest Additions to be installed. If it is not installed, follow the instruction in the Base ubuntu11.10 VM section.

Sharing works as long as one does not create symbolic links in the shared directory on the host.  This is a bug that was introduced in VirtualBox 4.1.8

```sh
# Share a folder on the host
# Select the VM Window
# Choose from the menu, Devices | Shared Folders...
# Click the + folder icon. 
# In the Folder Path combo box, popup the menu, choose other, and select the <host-project-dir>.
# To make the folder permanent and automatically mount upon boot, also check Make Permanent.
# Note the content of the folder name text box which well be referred to later as <share-folder-name>.
# Click Okay and dismiss the Shared Folders dialog box

# In your vm shell, mount the shared folder under the user home dir at the path <guest-project-dir>.
# Identify the current user user id, and group id.
id
# Look for the uid=<uid>, and gid=<gid>. Remember those ids.

# Create the directory to be use as a mount point, and mount the shared folder there.
# Replace <guest-project-dir>, <uid>, <gid>, <share-folder-name>, <guest-project-dir>
mkdir ~/<guest-project-dir>
sudo mount -t vboxsf -o uid=<uid>,gid=<gid> <share-folder-name> ~/<guest-project-dir>

# To make the folder permanent and automatically mount upon boot, first determine the path of the mounted dir.
# This output is referred to as <output-of-echo-cmd>
echo ~/<guest-project-dir>
# Then edit the rc.local file
sudo vi /etc/rc.local
# And add the following command right before the `exit 0` line
mount -t vboxsf -o uid=<uid>,gid=<gid> <share-folder-name> <output-of-echo-cmd>
```

## IP Address Allocation for vboxnet0 host-only network

Development Servers

* 192.168.56.10 - 192.168.56.22

Reserve for private use

* 192.168.56.150 - 192.168.56.199

DHCP

* 192.168.56.200 - 192.168.56.254

---
Copyright © Beachside Coders LLC, 2013

