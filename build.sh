#!/bin/bash
pushd "$(dirname $0)" >/dev/null

if [ "$(whoami)" != "root" ]; then
	echo "Must be root."
	exit 1
fi

BUILD_DIR="/usr/src/ax/build"
CONFIG_DIR="$1"
if [ "$1" = "" ]; then
	CONFIG_DIR="/etc/ax"
fi
if [ ! -d "$CONFIG_DIR" ]; then
	echo "Configuration directory does not exist: $CONFIG_DIR"
	exit 1
fi

# After the configuration has been copied into the destination etc/ax,
# the CONFIG_DIR variable will change to destination etc/ax directory.

if [ ! -d build ]; then
	mkdir -p build
fi
pushd "build"
if [ "$(pwd)" != "$BUILD_DIR" ]; then
	echo "Hängslen och svångrem."
	exit 1
fi

lb clean
rm -Rf * .build

# To remove kernel output during boot, add this to bootappend-live: quiet loglevel=0
lb config \
	-a amd64 \
	--bootappend-live "boot=live components keyboard-layouts=se live-config.hostname=machine live-config.timezone=Europe/Zurich live-config.user-default-groups=cdrom,floppy,sudo,audio,dip,video,plugdev,users,user,netdev,docker" \
	--parent-mirror-bootstrap http://ftp.se.debian.org/debian/ \
	--parent-mirror-binary http://ftp.se.debian.org/debian/ \
	--parent-mirror-chroot-security http://security.debian.org/ \
	--mirror-bootstrap http://ftp.se.debian.org/debian/ \
	--mirror-binary http://ftp.se.debian.org/debian/ \
	--mirror-chroot-security http://security.debian.org/ \
	--archive-areas "main contrib non-free non-free-firmware" \
	--apt-recommends true \
	--debootstrap-options "--include=apt-transport-https,ca-certificates,openssl" \
	--checksums none \
	--distribution bookworm \
	--image-name "ax" \
	--memtest none \
	--security true \
	--updates true \
	--system live \
	--verbose \
	--win32-loader false \
	--iso-application "ax" \
	--iso-preparer "johndoe@example.org" \
	--iso-publisher "ax" \
	--iso-volume "ax ($(date --rfc-3339=date))"

echo "! Packages Priority standard" > config/package-lists/standard.list.chroot

# ---------------------
#  COPY AX CONFIGURATION
# --------------------------

pushd "$CONFIG_DIR" >/dev/null
mkdir -p "$BUILD_DIR/config/includes.chroot/etc/ax"
rsync -avR . "$BUILD_DIR/config/includes.chroot/etc/ax/"
popd >/dev/null
CONFIG_DIR="$BUILD_DIR/config/includes.chroot/etc/ax"
chown root:root "$CONFIG_DIR"
find "$CONFIG_DIR" -type f -exec chmod 400 "{}" \;
find "$CONFIG_DIR" -type d -exec chmod 500 "{}" \;

# ---------------------
#  DOCKER
# ---------------
echo "deb http://download.docker.com/linux/debian bookworm stable" >config/archives/docker.list.chroot
curl https://download.docker.com/linux/debian/gpg >config/archives/docker.key.chroot
cp config/archives/docker.list.chroot config/archives/docker.list.binary
cp config/archives/docker.key.chroot config/archives/docker.key.binary
echo "docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin" >config/package-lists/docker.list.chroot

# ---------------------
#  FONTS
# -------------------------
echo "fonts-firacode fonts-noto-core fonts-noto-mono fonts-noto-extra fonts-noto-ui-core fonts-noto-color-emoji" >config/package-lists/fonts.list.chroot
# Hack font installed from Nerd Fonts by hook

# --------------------m
#  NODEJS
# ---------------
NODE_MAJOR=20
echo "deb https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" >config/archives/nodejs.list.chroot
curl https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key >config/archives/nodejs.key.chroot
cp config/archives/nodejs.list.chroot config/archives/nodejs.list.binary
cp config/archives/nodejs.key.chroot config/archives/nodejs.key.binary
echo "nodejs" >config/package-lists/nodejs.list.chroot

# --------------------
#  GOLANG
# ----------------
echo "golang" >config/package-lists/golang.list.chroot

# ---------------------
#  KUBERNETES
# ------------------
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key >config/archives/kubernetes.key.chroot
echo 'deb https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' > config/archives/kubernetes.list.chroot
echo "kubelet kubeadm kubectl" >config/package-lists/kubernetes.list.chroot

# ---------------------
#  BUILD TOOLS
# --------------------
echo "build-essential" >config/package-lists/buildtools.list.chroot

# -----------------
#  SSHD
# ----------------
echo "openssh-server" >config/package-lists/sshd.list.chroot

# -------
#  CERT STUFF
# ----------
echo "gnutls-bin" >config/package-lists/cert.list.chroot

# -------------------------
#  COMMAND LINE TOOLING
# ---------------------------
echo "exa htop jq neofetch p7zip-full timelimit tmux unzip" >config/package-lists/clitools.list.chroot

# --------------------
#  WINDOW MANAGER
# ------------------
echo "xorg xinit i3 i3lock i3lock-fancy feh polybar picom" >config/package-lists/wm.list.chroot
# i3 config is in skel/.config/i3/config
# picom config is in skel/.config/picom
pushd "config/packages.chroot" >/dev/null
wget https://github.com/Ulauncher/Ulauncher/releases/download/5.15.6/ulauncher_5.15.6_all.deb
popd >/dev/null

# -------------------------
#  SCREEN SHOTS
# --------------------
echo "maim" >config/package-lists/screenshots.list.chroot

# -----------------
#  TERMINAL
# ----------------------
echo "alacritty" >config/package-lists/terminal.list.chroot

# -------------------
#  NETWORKING
# -----------------
echo "bind9-dnsutils iwd net-tools whois" >config/package-lists/wifi.list.chroot
# iwd configuration is in hooks/iwd.hook.chroot

# -------------------
#  VPN
# -----------------
echo "nebula wireguard" >config/package-lists/vpn.list.chroot

# ----------------
#  WEB BROWSER
# ------------------
echo "curl chromium firefox-esr torbrowser-launcher" >config/package-lists/webbrowser.list.chroot

# -------------------
#  EDITOR
# -----------------------
echo "neovim" >config/package-lists/editor.list.chroot
pushd "config/packages.chroot" >/dev/null
wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
popd >/dev/null

# ----------------------
#  AUDIO
# --------------------
echo "pulseaudio libpulse-dev pavucontrol" >config/package-lists/audio.list.chroot

# --------------------------------
#  DATABASE STUFF
# -------------------------------
echo "mariadb-client mycli" >config/package-lists/db.list.chroot

# --------------------------
#  MISC STUFF
# ----------------------
# apache2-utils for installing htpasswd
echo "psmisc apache2-utils" >config/package-lists/misc.list.chroot

# -------------------
#  GIT
# --------------
echo "git tig" >config/package-lists/git.list.chroot
# settings global git stuff in hooks/git.hook.chroot

# ------------------
#  YUBIKEY
# -------------------
echo "usbutils gnupg pcscd scdaemon pinentry-gnome3" >config/package-lists/yubi.list.chroot

# -------------------------------------------
#  PASSWORD MANAGER
# ----------------------------------
echo "pass oathtool" >config/package-lists/password.list.chroot

# ---------------------------------------
#  AWS
# -----------------------------------
echo "awscli" >config/package-lists/aws.list.chroot

# -----------------
#  TORRENT
# --------------
echo "transmission" >config/package-lists/torrent.list.chroot

# ------------------
#  FTP
# -------------
echo "filezilla" >config/package-lists/ftp.list.chroot

# ------------------------
#  AUDIO/VIDEO/MEDIA
# ---------------------
echo "audacity ffmpeg gimp vlc" >config/package-lists/media.list.chroot

# --------------------
#  ANARCHISM
# ----------------
echo "anarchism fortune-anarchism" >config/package-lists/anarchism.list.chroot

# ----------------
#  COPY HOOKS FILES
# ------------------
pushd "../hooks" >/dev/null
rsync -avR . ../build/config/hooks/live/
popd >/dev/null

# ----------------
#  COPY SKEL FILES
# ------------------
pushd "../skel" >/dev/null
mkdir -p ../build/config/includes.chroot/etc/skel/
rsync -avR . ../build/config/includes.chroot/etc/skel/
chown -R root:root ../build/config/includes.chroot/etc/skel
popd >/dev/null

# ----------------
#  BINS
# ------------------
pushd "../bin" >/dev/null
mkdir -p ../build/config/includes.chroot/usr/local/bin
rsync -avR . ../build/config/includes.chroot/usr/local/bin/
chown -R root:root ../build/config/includes.chroot/usr/local/bin
chmod -R 755 ../build/config/includes.chroot/usr/local/bin
popd >/dev/null

# ----------------
#  BOOT SCRIPTS
# ------------------
pushd "../bootscripts" >/dev/null
mkdir -p ../build/config/includes.chroot/lib/live/config
rsync -avR . ../build/config/includes.chroot/lib/live/config/
chown -R root:root ../build/config/includes.chroot/lib/live/config
chmod -R 755 ../build/config/includes.chroot/lib/live/config
popd >/dev/null

# --------------------------
#  STUFF TO BUILD THIS DISTRO
# ---------------------
echo "live-build" >config/package-lists/livebuild.list.chroot
pushd ".." >/dev/null
mkdir -p build/config/includes.chroot/usr/src/ax
rsync -avR --exclude "build" . build/config/includes.chroot/usr/src/ax/
mkdir build/config/includes.chroot/usr/src/build
popd >/dev/null

# ------------------
#  BOOTLOADERS
# ---------------
mkdir -p config/bootloaders
pushd config/bootloaders >/dev/null
rsync -arv /usr/share/live/build/bootloaders/ .
sed -i 's/timeout 0/timeout 2/' extlinux/extlinux.conf
sed -i 's/default 0/default 0\ntimeout 2/' grub-legacy/menu.lst
sed -i 's/set default=0/set default=0\nset timeout=2/' grub-pc/config.cfg
sed -i 's/timeout 0/timeout 2/' isolinux/isolinux.cfg
sed -i 's/timeout 0/timeout 2/' pxelinux/pxelinux.cfg/default
sed -i 's/timeout 0/timeout 2/' syslinux/syslinux.cfg

popd >/dev/null

# -------------------------------
#  USER PASSWORD
# ----------------------------

# Generate password hash like this:
# printf "mypassword" | mkpasswd --stdin --method=sha-512
# (mkpasswd is in the whois package. apt install whois.)
if [ -f "$CONFIG_DIR/passwd/user" ]; then
	cat <<_EOF_ >config/includes.chroot/lib/live/config/0035-passwd
#!/bin/bash
printf 'user:$(cat $CONFIG_DIR/passwd/user | head -1)' | chpasswd -e
_EOF_
fi

# -------------------------
#  AUTHORIZED_KEYS
# ----------------------
if [ -d "$CONFIG_DIR/authorized_keys" ]; then
	pushd "$CONFIG_DIR/authorized_keys" >/dev/null
	mkdir -p "$BUILD_DIR/config/includes.chroot/etc/ssh/authorized_keys"
	rsync -avR . "$BUILD_DIR/config/includes.chroot/etc/ssh/authorized_keys/"
	popd >/dev/null
fi

# ---------------
#  BUILD IT!
# -------------
PATH="$PATH:/sbin:/usr/sbin" lb build --verbose --debug --color | tee ./build.log

popd >/dev/null

popd >/dev/null
