#!/usr/bin/env bash

MOUNT_DIR=".pi-mount"

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--host)
      HOST="$2"
      shift # past argument
      shift # past value
      ;;
    -k|--key)
      SSH_KEY="$2"
      shift # past argument
      shift # past value
      ;;
    --cores)
      CORES="$2";
      shift # past argument
      shift # past value
      ;;
    --max-jobs)
      MAX_JOBS="$2";
      shift # past argument
      shift # past value
      ;;
  esac
done

if [[ -z "$HOST" ]]; then
  echo "No host specified, exiting"
  exit 1
fi

if [[ -z "$SSH_KEY" ]]; then
  echo "No host key specified, exiting"
  exit 1
fi

echo "Building host '${HOST}', with builders '${BUILDERS}', then injecting key ${SSH_KEY}"

actual_pubkey=$(ssh-keygen -y -f "$SSH_KEY")
expected_pubkey=$(nix eval --file secrets/secrets.nix --json | jq -r ".systems.$HOST")

if [[ $actual_pubkey != "$expected_pubkey"* ]]; then
  echo "Wrong host key specified, got:"
  echo "$actual_pubkey"
  echo "Expected:"
  echo "$expected_pubkey"
  exit 1
fi

echo -e "\nDeleting existing images"
sudo umount $MOUNT_DIR
rm -rf $MOUNT_DIR
rm -rf nixos-sd-image-*-aarch64-linux.img*

set -e

echo -e "\nBuilding image"
nom build ".#images.$HOST" --cores ${CORES:-4} --max-jobs ${MAX_JOBS:-4}

echo -e "\nCopying image"
rsync -ah --progress result/sd-image/nixos-sd-image-*-aarch64-linux.img .

echo -e "\nMounting image"
fdisk -l nixos-sd-image-*-aarch64-linux.img
blocknum=$(fdisk -l nixos-sd-image-*-aarch64-linux.img | awk '/Linux/ {print $3}')
offset=$(($blocknum * 512))
mkdir -p $MOUNT_DIR
sudo mount -o loop,offset=$offset nixos-sd-image-*-aarch64-linux.img $MOUNT_DIR

echo -e "\nInjecting SSH key"
sudo mkdir -p $MOUNT_DIR/etc/ssh
# TODO: DETECT KEY TYPE
sudo cp $SSH_KEY $MOUNT_DIR/etc/ssh/ssh_host_ed25519_key
echo $actual_pubkey | sudo tee $MOUNT_DIR/etc/ssh/ssh_host_ed25519_key.pub

echo -e "\nUnmounting image"
sudo umount $MOUNT_DIR

