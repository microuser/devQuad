# devQuad

## Constructor Creator 
an app for later

## nixOS UEFI Secure Boot Plama Installer
```sh
cd ~/Downloads
wget 'https://channels.nixos.org/nixos-23.05/latest-nixos-plasma5-x86_64-linux.iso'
echo 'more architectures at https://nixos.org/download'

sudo dd if=~/Downloads/latest-nixos-plasma5-x86_64-linux.iso of=/dev/XXX_USB1_XXX status=progress 
```
Press Power button when system is off.
Enter BIOS mode, F2, Delete, F10 are common. 
If BIOS is EFI already, you may need to turn off secure boot
it is best to actually get your system to read the secure boot keys first. EFI USB boot is possible.
It it most reasonanle to turn turn off secure boot for installation, doing EFI install. Then turing secure boot back on. Usually the key handling is slightly easier. Look for boot.efi and linthe linux kernel boot hash

Turn EFI on off or on
Do the install, partion using the AUTO disk whole if possible. Otherwise, EFI boot for a 100meg partiton fat32 with only boot. sometimes just first partition is enough, depending on crazy size or SSD newness.


install

verify secure boot keys,
re-enable secureboot

boot with EFI logo

take note of networking interface names.

