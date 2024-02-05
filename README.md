# ax

Live Linux distribution built on Debian Bookworm (12).

## Installed Features

### Generic

* Live system on readonly USB.
* Tiling window manager `i3`.

### Command line environment

* [Alacritty](https://github.com/alacritty/alacritty) terminal
* [starship](https://starship.rs/) prompt

### Security features

* Yubikey for SSH auth
* Yubikey for GPG
* [Ripasso](https://github.com/cortex/ripasso/) password manager (on top of the standard unix password manager `pass`)

### VPN

* Nebula
* Wireguard

### Editors

* Neovim
* VSCode

### Version control

* git
* Command line tooling for git:
	* [grv](https://github.com/rgburke/grv) (Git Repository Viewer)
	* [Lazygit](https://github.com/jesseduffield/lazygit) 
	* [tig](https://github.com/jonas/tig) (Text-mode interface for Git)

### Programming languages/compilers/runtimes

* nodejs (javascript)
* golang

### Container tooling

* docker
* kubernetes

### Web browsers

* Firefox
* Chromium
* TOR Browser

### Misc tooling for developers

* AWS CLI
* Hack font (typeface designed for source code)

## Configuration

At boot time, ax will look through all your disks, searching for ext4 partitions with the file `/.ax/mounts` on it.

The `/.ax/mounts` file lists paths on the ext4 partiontions that should be bind mounted to specific paths in your filesystem.

Example:

```
/ax/myauthkeys:/etc/ssh/authorized_keys
/ax/nebulaconfig:/etc/nebula
```

This would bind mount `/ax/myauthkeys` to the mointpoint `/etc/ssh/authorized_keys` and `/ax/nebulaconfig` to the mountpoint `/etc/nebula`.

This way, you can adapt the configuration by mounting configs to correct paths.

## Persistent storage

Just as you can mount configuration using `/.ax/mounts`, you can also use the mounts for persistent storage.

Note: The user home directory (`/home/user`) is created at boot and can not be persisted.

## Persisting your WIFI network information

Use the `iwctl` command to make your WIFI configuration.

Make a bind mount at `/var/lib/iwd` to persist your WIFI configuration. Example `/.ax/mounts`:

```
/opt/my-wifi-stuff:/var/lib/iwd
```

## Persisting your hostkeys

To persist your SSH host keys between reboots, do a bind mount at the mountpoint `/etc/ssh/hostkeys`.

Example `/.ax/mounts`:

```
/ax/my-ssh-hostkeys:/etc/ssh/hostkeys
```

## Persisting authorized keys

The persist your authorized_keys, do a bind mount at the mountpoint `/etc/ssh/authorized_keys` and put a file called `user` in it, with your authorized ssh keys (using normal `authorized_keys` format.)

## Running Nebula VPN on ax

Make a bind mount on `/etc/nebula` and put your nebula configuration there. If there is a `/etc/nebula/config.yml`, the nebula daemon will start at boot time

## Running Kubernetes on ax

AX can be used for running a Kubernetes cluster.

### Step 1: Nebula VPN

The default Kubernetes configuration on ax was made for having a nebula VPN running, and Kubernetes nodes communicating over the VPN.

By default, AX was made to use `172.24.0.0/18` for the VPN, and `172.24.0.1` for the first control plane node. This configuration can be changed by bind mounting on `/etc/ax/kubernetes` with other values in the `config.env` file.

Make sure to allow TCP traffic on ports `6443` and `10250` between the Kubernetes nodes.

### Step 2: Bind mounts for persistency and configuration

To run Kubernetes on ax, you have to do bind mounting of those mountpoints (for configuration and perstistent storage):

* `/var/lib/cni`
* `/var/lib/etcd`
* `/var/lib/kubelet`
* `/etc/cni/net.d`
* `/etc/kubernetes`
* `/opt/cni/bin` (with `livecopy` option)
* `/usr/libexec/kubernetes`

### Step 3: Create control plane node

On your `172.24.0.1` (if using the default config) machine, run the script `k8s-create-cluster` to make it your first control plane.

### Step 4: CNI

Install your CNI of choice.

### Sten 5: Make other AX machines into kubernetes worker nodes

On other machines, run `k8s-join-worker-node` and follow the instructions, to make them worker nodes.