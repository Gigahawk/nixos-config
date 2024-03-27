# nixos-config

## Adding a new host

### Creating a new user password

1. Generate a new password using `mkpasswd -m sha-512`
2. Copy it into an agenix secret
3. Reference the secret in `users.users.<name>.hashedPasswordFile`

### Creating a new Syncthing config

1. Generate a new set of keys using `syncthing -generate=<foldername>`
2. Import the `cert.pem` and `key.pem` files into agenix
3. Copy the device ID from `config.xml` into `modules/syncthing.nix`
    - Add the device to any folders it should share
4. Generate a GUI password using `bcrypt-tool hash <password> 10`
5. Add `modules/syncthing.nix` to the import list for the host
6. Define all relevant options (paths, etc.) in the host `configuration.nix`

## Hosts

### Servers (virtualbox, ptolemy)

- `virtualbox`
    - Virtualbox host to experiment with server setup before committing to real hardware
- `ptolemy`
    - Main server
    - Syncthing device ID: `DVSWOT3-6RE3PRD-OB3IVQI-VELDUFR-EMHZZCR-MPGNVW3-EIHW4LK-REFXVAJ`
- `haro`
    - Pi KVM connected to `ptolemy`

#### Samba bootstrapping

After a fresh install, add user passwords with `smbpasswd -a <user>`

#### Backups

Hosts containing important data are backed up to Storj using restic.

The latest backup can be restored by running
```
sudo restic-storj restore --target <path_to_restore_to> latest
```

#### SnapRAID drive replacement procedure

Simulation of a reboot after a complete drive failure (no longer detected etc.)

1. Shutdown machine
1. Replace the bad drive in the machine
1. Reboot the machine, it should fail to boot, dropping you to a recovery prompt
1. Type in the root password to get to the shell
1. Run `lsblk -l -o NAME,SIZE,LABEL,MODEL,SERIAL` to figure out which drive is the new one (should have no label)
1. Run `mkfs.ext4 -m 0 -L <missing label> /dev/sd<new disk>`
    - If no replacement drive is available, you may try to reuse the bad drive by reformatting with the `-cc` option to have the new filesystem avoid detected bad blocks
1. Press `Ctrl+D` to continue booting
1. Once logged in, run `snapraid -l /tmp/snapraid-fix.log fix`
    - Add `-d <disk name>` to only target the replaced drive


#### InvenTree Setup

1. Generate a new secret key with `inventree-gen-secret`, import into agenix
1. Map it into the config with permissions ??? and ownership ???

#### InvenTree bootstrapping

1. Clone `git@github.com:Gigahawk/inventree-backup.git` to `/mnt/pool/inventree-backup`
    - This path is required for the automated backup script to work
2. Copy `data.json` from the repo to `/mnt/pool/inventree-data`
3. Copy the files in `media` to `/mnt/pool/inventree-data/media`
    - Files that can be skipped:
        - `maintenance_mode*`
        - `report/`
        - `label/`
4. Run `sudo arion run inventree-server invoke import-records -c -f data/data.json`
    - This should import the entire database, including user accounts
    - If there are warnings about (image) files missing, make sure step 3 was completed properly
4. Run `sudo arion run inventree-server invoke update`

## Building Raspberry Pi Images

1. Run `nix build .#images.<host>`
    - In order to build on non-NixOS hosts, install `qemu-user` (for Ubuntu see [this link](https://azeria-labs.com/arm-on-x86-qemu-user/)), then add `extra-platforms = aarch64-linux` to your `nix.conf`
1. Copy the image out of `result/sd-image/` to your local directory
1. Extract the `.zst` file with `unzstd`
1. Mount the extracted image with fdisk etc.
1. 


## Non-NixOS Hosts

### Syncthing

Instead of building the Syncthing config directly, the NixOS module builds a
shell script that configures Syncthing through the API.
Unfortunately this means that it is basically impossible to use Nix to
declaratively manage non-NixOS Syncthing hosts.

Instead, a "mostly" complete config will have to be copied from a NixOS host,
tweaked, then imported.
Generally:
1. Do a fresh setup of Syncthing on the machine
2. Copy the device ID into `modules/syncthing.nix`, add device to any shared folders
3. Build the config on a NixOS host.
    - Use a host that has access to all folders needed by the target host
4. Copy the config off of the NixOS host
5. Do any modifications necessary (see below for details)
    - Modify the `path` attribute of all `folder` tags (the web GUI doesn't let you modify them after creation)
6. Copy the modified config to the target host (see below for details)

#### Windows

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

#### Android

Install [Syncthing-Fork](https://play.google.com/store/apps/details?id=com.github.catfriend1.syncthingandroid&hl=en&gl=US)

Folder paths are standard Android internal storage paths (i.e. `/storage/emulated/0/DCIM`)

You can import the config by doing the following:
1. Go to the `Status` tab
2. Tap the settings gear in the top right corner
3. Tap `Import and Export`
4. Tap `Export Configuration`
    - WARNING: This will export your private key, ensure you delete
    `<Internal storage>/backup/syncthing` afterwards
5. Copy your modified `config.xml` to `<Internal storage>/backup/syncthing`,
   overwriting the existing file
4. Tap `Import Configuration`
5. Securely delete all files in `<Internal storage>/backup/syncthing`

##### Common folder paths

- Documents: `/storage/emulated/0/Documents`
- Music: `/storage/emulated/0/Music`
- pdf2remarkable: `/storage/emulated/0/pdf2remarkable`
- remarkable_sync: `/storage/emulated/0/remarkable_sync`

#### reMarkable

> TODO: figure out how installation works from toltec and service stuff

Ensure the `type` attribute of the `remarkable_sync` folder is set to `sendonly`