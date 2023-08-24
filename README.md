# nixos-config


## Hosts

### virtualbox

Virtualbox host to experiment with server setup before committing to real hardware

#### SnapRAID drive replacement procedure

Simulation of a reboot after a complete drive failure (no longer detected etc.)

1. Disconnect drive from VM
1. Create a new blank drive and insert it.
1. Reboot the VM
1. VM should fail to boot, dropping you to a recovery prompt
1. Type in the root password to get to the shell
1. Run `lsblk` to figure out which drive is the new one (should have no mountpoint)
1. Run `mkfs.ext4 -m 0 -L <missing label> /dev/sd<new disk>`
1. Press `Ctrl+D` to continue booting
1. Once logged in, run `snapraid -l /tmp/snapraid-fix.log fix`
    - Add `-d <disk name>` to only target the replaced drive


#### InvenTree bootstrapping

Clone `git@github.com:Gigahawk/inventree-backup.git` to `/mnt/pool/inventree-backup` for backups to work properly

