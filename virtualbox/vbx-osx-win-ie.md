# VirtualBox - OS X - Windows - IE Test Environment


## VirtualBox Setup

* Download 

```sh

# Windows 7 with IE 8
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar,6.rar}"

# Windows 7 with IE 9
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar}"
```

* Create OVF from SFX

```sh
chmod +x <filename>.sfx

./<filename>.sfx
```

* Import OVF in VirtualBox

	* File -> Import Appliance
	* Set minimum RAM settings to 1024MB
	
* Setup Host Network

	* Click on settings
	* Select Network tab
	* Select Adapter 2 tab
	* Enable, attach to the Host-only Adapter (vboxnet0)


* Add Guest Additions
	
	* Devices -> Guest Additions


## References

* http://www.modern.ie/en-us/virtualization-tools#downloads

* http://chriswharton.me/2013/02/installing-modern-ie-virtualization-on-virtualbox-for-mac/

* https://modernievirt.blob.core.windows.net/vhd/virtualmachine_instructions_2013-07-22.pdf



---
Copyright © Beachside Coders LLC, 2013

