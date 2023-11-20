# nixos-config

## Adding a new host

### Creating a new user password

1. Generate a new password using `mkpasswd -m sha-512`
2. Copy it into an agenix secret
3. Reference the secret in `users.users.<name>.hashedPasswordFile`

### Creating a new Syncthing config

1. Generate a new set of keys using `syncthing -generate=<foldername>`
2. Import the `cert.pem` and `key.pem` files into agenix
3. Copy the device ID from `config.xml` into the config
4. Generate a GUI password using `bcrypt-tool hash <password> 10`

## Hosts

### Servers (virtualbox, ptolemy)

- `virtualbox`
    - Virtualbox host to experiment with server setup before committing to real hardware
- `ptolemy`
    - Main server
    - Syncthing device ID: `DVSWOT3-6RE3PRD-OB3IVQI-VELDUFR-EMHZZCR-MPGNVW3-EIHW4LK-REFXVAJ`

#### Samba bootstrapping

After a fresh install, add user passwords with `smbpasswd -a <user>`

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
