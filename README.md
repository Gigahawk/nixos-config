# nixos-config

<!-- vscode-markdown-toc -->

-
  1. [Adding a new host](#Addinganewhost)
  - 1.1. [Installing](#Installing)
  - 1.2. [Setting up a host ssh key](#Settingupahostsshkey)
  - 1.3. [Creating a new user password](#Creatinganewuserpassword)
  - 1.4. [Creating a user ssh key](#Creatingausersshkey)
  - 1.5. [Creating a new Syncthing config](#CreatinganewSyncthingconfig)
-
  2. [Updating](#Updating)
  - 2.1. [Locally](#Locally)
  - 2.2. [Remotely](#Remotely)
-
  3. [Tailscale](#Tailscale)
  - 3.1. [Renewing Keys](#RenewingKeys)
  - 3.2. [DNS Failures](#DNSFailures)
-
  4. [Hosts](#Hosts)
  - 4.1. [Servers (virtualbox, ptolemy)](#Serversvirtualboxptolemy)
    - 4.1.1. [Samba bootstrapping](#Sambabootstrapping)
    - 4.1.2. [Backups](#Backups)
    - 4.1.3.
      [SnapRAID drive replacement procedure](#SnapRAIDdrivereplacementprocedure)
    - 4.1.4. [InvenTree Setup](#InvenTreeSetup)
    - 4.1.5. [InvenTree bootstrapping](#InvenTreebootstrapping)
  - 4.2. [WSL (veda)](#WSLveda)
    - 4.2.1. [SystemD/D-Bus issues](#SystemDD-Busissues)
  - 4.3. [Raspberry Pi Images](#RaspberryPiImages)
    - 4.3.1. [Building Raspberry Pi Images](#BuildingRaspberryPiImages)
-
  5. [Non-NixOS Hosts](#Non-NixOSHosts)
  - 5.1. [Syncthing](#Syncthing)
    - 5.1.1. [Windows](#Windows)
    - 5.1.2. [Android](#Android)
    - 5.1.3. [reMarkable](#reMarkable)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## 1. <a name='Addinganewhost'></a>Adding a new host

### 1.1. <a name='Installing'></a>Installing

> WARNING: THIS WILL WIPE THE SYSTEM

> WARNING: IF YOU ARE REINSTALLING, ENSURE YOU HAVE A COPY OF THE SSH HOST KEYS
> FOR THE SYSTEM. AGENIX WILL NEED THESE TO BOOT PROPERLY.

> Partially based on https://www.notashelf.dev/posts/impermanence

1. Boot into a NixOS installer
2. Run the following commands to format and partition the boot drive

```bash
export DISK=/dev/sdX # use target disk

# Set up GPT
parted "$DISK" -- mklabel gpt

# Set up boot partition
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB  # Use a larger value like 2GiB to store more generations
parted "$DISK" -- set 1 boot on # Do this for UEFI support?
mkfs.vfat -n BOOT "$DISK"1

# Set up swap partition
parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB  # For an 8GiB swap partition

# Set up root partition
parted "$DISK" -- mkpart primary ext4 9GiB 100%  # Assuming swap ends at 9GiB

# Set up encrypted swap
cryptsetup --verify-passphrase -v luksFormat --label swap_encrypted "$DISK"2
cryptsetup open "$DISK"2 swap_decrypted  # mount encrypted swap to /dev/mapper/swap_decrypted
mkswap -L swap /dev/mapper/swap_decrypted  # create up swap fs
swapon /dev/disk/by-label/swap

# Set up encrypted root
cryptsetup --verify-passphrase -v luksFormat --label nixos_encrpyted "$DISK"3
cryptsetup open "$DISK"3 nixos_decrypted  # mount encrypted volume to /dev/mapper/nixos_decrypted
mkfs.ext4 -L nixos /dev/mapper/nixos_decrypted  # create root fs
```

3. Mount the drive for install

```bash
mount /dev/disk/by-label/nixos /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot
```

4. Copy or generate host ssh keys with correct permissions:
   - See below for key generation details

```
$ ls -al /mnt/etc/ssh/ssh_host*
-r-------- 1 root root 399 Nov 15  2023 /mnt/etc/ssh/ssh_host_ed25519_key
-rw-r--r-- 1 root root  94 Nov 15  2023 /mnt/etc/ssh/ssh_host_ed25519_key.pub
```

5. If this is a new host, generate a new config with
   `nixos-generate-config --root /mnt`, then copy to this flake and modify as
   needed.
6. Install with `nixos-install --flake github:Gigahawk/nixos-config#<hostname>`
   - If you get out of space errors set `TMPDIR=/mnt/flake/tmp`. You may need to
     garbage collect with `nix-collect-garbage` or even reboot the installer and
     remount after the first error.
     - Also might have to randomly
       `mkdir -p /mnt/flake/tmp/nix-build-mounts.sh.drv-0` for some reason?

### 1.2. <a name='Settingupahostsshkey'></a>Setting up a host ssh key

1. Login as root on a freshly installed host
2. Create a host ssh key with `ssh-keygen -t ed25519 -C "root@<hostname>"`
   - Ensure the key is saved as `/mnt/etc/ssh/ssh_host_ed25519_key`
   - Ensure no password is set
3. Run `cat /mnt/etc/ssh/ssh_host_ed25519_key.pub` and add it to the list of
   hosts in `secrets/secret.nix`

### 1.3. <a name='Creatinganewuserpassword'></a>Creating a new user password

1. Generate a new password using `mkpasswd -m sha-512`
2. Copy it into an agenix secret
3. Reference the secret in `users.users.<name>.hashedPasswordFile`

For WSL installs see
https://nix-community.github.io/NixOS-WSL/how-to/change-username.html for how to
properly switch users

### 1.4. <a name='Creatingausersshkey'></a>Creating a user ssh key

1. Login as the user
2. Create a ssh key with `ssh-keygen -t ed25519 -C "<username>@<hostname>"`
3. Run `cat ~/.ssh/id_ed25519.pub` and add it to the list of users in
   `secrets/secret.nix`
4. On an existing machine, run `agenix -r` to in the `secrets` directory to
   rekey all secrets.
   - Comment out the `inherit systems;` line to prevent agenix from attempting
     and failing to rekey it

### 1.5. <a name='CreatinganewSyncthingconfig'></a>Creating a new Syncthing config

1. Generate a new set of keys using `syncthing -generate=<foldername>`
2. Import the `cert.pem` and `key.pem` files into agenix
3. Copy the device ID from `config.xml` into `modules/syncthing.nix`
   - Add the device to any folders it should share
4. Generate a GUI password using `bcrypt-tool hash <password> 10`
5. Add `modules/syncthing.nix` to the import list for the host
6. Define all relevant options (paths, etc.) in the host `configuration.nix`

## 2. <a name='Updating'></a>Updating

### 2.1. <a name='Locally'></a>Locally

All hosts come with a `nixos-update` script which under the hood calls
`nixos-rebuild` with arguments to fetch this repo from GitHub and show the build
output in `nix-output-monitor`

### 2.2. <a name='Remotely'></a>Remotely

For hosts that are performance limited, it may be faster (or required) to build
the updated config on a different host, and then push it. This can be done with

```
nixos-rebuild \
    --flake .#<hostname> \
    --target-host jasper@<target_ip> \
    --sudo --ask-sudo-password switch
```

## 3. <a name='Tailscale'></a>Tailscale

All hosts are connected via Tailscale.

### 3.1. <a name='RenewingKeys'></a>Renewing Keys

Eventually, the keys for a host will expire.

> Note that the
> [official docs](https://tailscale.com/kb/1028/key-expiry#renewing-keys-for-an-expired-device)
> instruct to run `tailscale up --force-reauth` to update keys which will appear
> to work, but this method does not persist a reboot since our key is stored in
> agenix

To renew the key:

1. Generate a new auth key from https://login.tailscale.com/admin/settings/keys
2. Update the relevant secrets file and push
3. Pull the updated config on the host
   - If you need Tailscale to access the device see the
     [official docs](https://tailscale.com/kb/1028/key-expiry#renewing-keys-for-an-expired-device)
     for how to temporarily regain access

### 3.2. <a name='DNSFailures'></a>DNS Failures

Occasionally DNS failures will prevent systems from reaching the internet (see
https://github.com/tailscale/tailscale/issues/13235).

Usually when this happens the device is still connected to Tailscale so it can
still be accessed over SSH.

Resetting the Tailscale service seems to fix this.

```
sudo systemctl restart tailscaled.service
sudo tailscale up
```

## 4. <a name='Hosts'></a>Hosts

### 4.1. <a name='Serversvirtualboxptolemy'></a>Servers (virtualbox, ptolemy)

- `virtualbox`
  - Virtualbox host to experiment with server setup before committing to real
    hardware
- `ptolemy`
  - Main server
  - Syncthing device ID:
    `DVSWOT3-6RE3PRD-OB3IVQI-VELDUFR-EMHZZCR-MPGNVW3-EIHW4LK-REFXVAJ`

#### 4.1.1. <a name='Sambabootstrapping'></a>Samba bootstrapping

After a fresh install, add user passwords with `smbpasswd -a <user>`

#### 4.1.2. <a name='Backups'></a>Backups

Hosts containing important data are backed up to Storj using restic.

The latest backup can be restored by running

```
sudo restic-storj restore --target <path_to_restore_to> latest
```

#### 4.1.3. <a name='SnapRAIDdrivereplacementprocedure'></a>SnapRAID drive replacement procedure

Simulation of a reboot after a complete drive failure (no longer detected etc.)

> These instructions are now for encrypted drives, ensure the `boot.initrd.luks`
> is setup correctly. For example:
>
> ```
>   boot.initrd.luks = {
>   reusePassphrases = true;
>   devices = {
>     data0_decrypted = {
>       device = "/dev/disk/by-label/data0_encrypted";
>     };
>   };
> };
> ```

1. Shutdown machine
1. Replace the bad drive in the machine
1. Reboot the machine, it should fail to boot, dropping you to a recovery prompt
   - Note that you may get
     `Cannot open access to console, the root account is locked.`, in this case,
     interrupt `systemd-boot` by pressing `e`, then adding
     `rescue systemd.setenv=SYSTEMD_SULOGIN_FORCE=1` to the end of the boot
     command
     - TODO: what are the security implications of this?
1. Type in the root password to get to the shell
1. Run `lsblk -l -o NAME,SIZE,LABEL,MODEL,SERIAL` to figure out which drive is
   the new one (should have no label)
1. Run
   `cryptsetup luksFormat --label <missing_label>_encrypted /dev/sd<new disk>`
   to setup an encrypted drive
1. Run
   `cryptsetup open /dev/disk/by-label/<missing_label>_encrypted <missing_label>_decrypted`
   to unlock the drive to `/dev/mapper/<missing_label>_decrypted`
1. Run `mkfs.ext4 -m 0 -L <missing label> /dev/mapper/<missing_label>_decrypted`
   - If no replacement drive is available, you may try to reuse the bad drive by
     reformatting with the `-cc` option to have the new filesystem avoid
     detected bad blocks
1. Press `Ctrl+D` to continue booting
1. Once logged in, run `snapraid -l /tmp/snapraid-fix.log fix`
   - Add `-d <disk name>` to only target the replaced drive
   - If replacing a parity drive use
     `snapraid -l /tmp/snapraid-sync.log --force-full sync`

#### 4.1.4. <a name='InvenTreeSetup'></a>InvenTree Setup

1. Generate a new secret key with `inventree-gen-secret`, import into agenix
1. Map it into the config with permissions ??? and ownership ???

#### 4.1.5. <a name='InvenTreebootstrapping'></a>InvenTree bootstrapping

1. Clone `git@github.com:Gigahawk/inventree-backup.git` to
   `/mnt/pool/inventree-backup`
   - This path is required for the automated backup script to work
2. Copy `data.json` from the repo to `/mnt/pool/inventree-data`
3. Copy the files in `media` to `/mnt/pool/inventree-data/media`
   - Files that can be skipped:
     - `maintenance_mode*`
     - `report/`
     - `label/`
4. Run
   `sudo arion run inventree-server invoke import-records -c -f data/data.json`
   - This should import the entire database, including user accounts
   - If there are warnings about (image) files missing, make sure step 3 was
     completed properly
5. Run `sudo arion run inventree-server invoke update`

### 4.2. <a name='WSLveda'></a>WSL (veda)

- `veda`
  - WSL install on Jasper-PC

#### 4.2.1. <a name='SystemDD-Busissues'></a>SystemD/D-Bus issues

If `systemctl --user` isn't working, try running some of the following

```
sudo loginctl enable-linger "$USER"
```

Run the following as root (this will break running Windows apps from bash, but
seems to work fine if you open a new WSL session)

```
bash -c \
"until [ -S /run/dbus/system_bus_socket ]; \
 do sleep 1; \
done; \
systemctl restart user@1000; \
export DBUS_SESSION_BUS_ADDRESS='unix:path/run/user/1000/bus'; \
exec sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS --user jasper bash"
```

### 4.3. <a name='RaspberryPiImages'></a>Raspberry Pi Images

- `haro`
  - Pi KVM connected to `ptolemy`

#### 4.3.1. <a name='BuildingRaspberryPiImages'></a>Building Raspberry Pi Images

1. Run `nix build .#images.<host>`
   - In order to build on non-NixOS hosts, install `qemu-user` (for Ubuntu see
     [this link](https://azeria-labs.com/arm-on-x86-qemu-user/)), then add
     `extra-platforms = aarch64-linux` to your `nix.conf`
1. Copy the image out of `result/sd-image/` to your local directory
1. Extract the `.zst` file with `unzstd`
1. Mount the extracted image with fdisk etc.
1. Copy over private keys?

## 5. <a name='Non-NixOSHosts'></a>Non-NixOS Hosts

### 5.1. <a name='Syncthing'></a>Syncthing

Instead of building the Syncthing config directly, the NixOS module builds a
shell script that configures Syncthing through the API. Unfortunately this means
that it is basically impossible to use Nix to declaratively manage non-NixOS
Syncthing hosts.

Instead, a "mostly" complete config will have to be copied from a NixOS host,
tweaked, then imported. Generally:

1. Do a fresh setup of Syncthing on the machine
2. Copy the device ID into `modules/syncthing.nix`, add device to any shared
   folders
3. Build the config on a NixOS host.
   - Use a host that has access to all folders needed by the target host
4. Copy the config off of the NixOS host
   - The config should be at `/etc/syncthing/config.xml` by default, check the
     `dataDir` attribute in the module.
5. Do any modifications necessary (see below for details)
   - Modify the `path` attribute of all `folder` tags (the web GUI doesn't let
     you modify them after creation)
6. Copy the modified config to the target host (see below for details)

#### 5.1.1. <a name='Windows'></a>Windows

Install [SyncTrazor](https://github.com/canton7/SyncTrayzor#installation)

Folder paths are typical Windows paths (i.e. `C:\Users\Jasper\Documents`)

Syncthing's config folder is usually at `%APPDATA%\..\Local\Syncthing`

##### Common folder paths

- Documents
  - JASPER-PC: `C:\Users\Jasper\Documents`
- Homework
  - JASPER-PC: `D:\Homework`
- Music
  - JASPER-PC: `D:\Music`
- pdf2remarkable
  - JASPER-PC: `D:\pdf2remarkable`
- remarkable_sync
  - JASPER-PC: `D:\remarkable_sync`

#### 5.1.2. <a name='Android'></a>Android

Install
[Syncthing-Fork](https://play.google.com/store/apps/details?id=com.github.catfriend1.syncthingandroid&hl=en&gl=US)

Folder paths are standard Android internal storage paths (i.e.
`/storage/emulated/0/DCIM`)

You can import the config by doing the following:

1. Go to the `Status` tab
2. Tap the settings gear in the top right corner
3. Tap `Import and Export`
4. Tap `Export Configuration`
   - WARNING: This will export your private key, ensure you delete
     `<Internal storage>/backup/syncthing` afterwards
5. Copy your modified `config.xml` to `<Internal storage>/backup/syncthing`,
   overwriting the existing file
6. Tap `Import Configuration`
7. Securely delete all files in `<Internal storage>/backup/syncthing`

##### Common folder paths

- Documents: `/storage/emulated/0/Documents`
- Music: `/storage/emulated/0/Music`
- pdf2remarkable: `/storage/emulated/0/pdf2remarkable`
- remarkable_sync: `/storage/emulated/0/remarkable_sync`

#### 5.1.3. <a name='reMarkable'></a>reMarkable

> TODO: figure out how installation works from toltec and service stuff

Ensure the `type` attribute of the `remarkable_sync` folder is set to `sendonly`

