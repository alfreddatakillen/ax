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
* WireGuard (VPN)

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
* kubernetes tooling (kubectl, kubeadm)
* kind for local kubernetes development

### Web browsers

* Firefox
* Chromium
* TOR Browser

### Misc tooling for developers

* AWS CLI
* Hack font (typeface designed for source code)

## Configuration

At boot time, ax will look through all your disk drives, searching for ext4 partitions with the file `/.ax/config.json` on it.

All partitions with that configuration file will be mounted as `/opt/servicemounts/<devicename>`.

Those configuration files may have those configuration options:

### `containerd-data-dir`

Pointing to a directory that containerd will use for it's data. Use `%MOUNTDIR%` to point to the mount directory for the partition for the corresponding configuration file. Example:

```
{
	"containerd-data-dir": "%MOUNTDIR%/var/lib/containerd"
}
```

The directory will be created by the containerd daemon if it does not exist.


### `docker-data-dir`

Pointing to a directory that docker will use for it's data. Use `%MOUNTDIR%` to point to the mount directory for the partition for the corresponding configuration file. Example:

```
{
	"docker-data-dir": "%MOUNTDIR%/var/lib/docker"
}
```

The directory will be created by the docker daemon if it does not exist.

