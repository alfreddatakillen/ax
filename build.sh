#!/bin/bash
pushd "$(dirname $0)" >/dev/null

if [ "$(whoami)" != "root" ]; then
	echo "Must be root."
	exit 1
fi

if [ ! -d build ]; then
	mkdir -p build
fi
pushd build >/dev/null

if [ "$(pwd)" != "/usr/src/ax/build" ]; then
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
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
echo "kubelet kubeadm kubectl" >config/package-lists/kubernetes.list.chroot

# ---------------------
#  BUILD TOOLS
# --------------------
echo "build-essential" >config/package-lists/buildtools.list.chroot

# -----------------
#  SSHD
# ----------------
echo "openssh-server" >config/package-lists/sshd.list.chroot

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
echo "iwd" >config/package-lists/wifi.list.chroot
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

# --------------------------
#  MISC STUFF
# ----------------------
echo "psmisc" >config/package-lists/misc.list.chroot

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
echo "filezilla" >/config/package-lists/ftp.list.chroot

# ---------------
#  VIDEO
# ------------
echo "vlc" >config/package-lists/video.list.chroot

# --------------
#  IMAGE EDITING
# ----------------
echo "gimp" >config/package-lists/imgedit.list.chroot

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
rsync -avR --exclude "build" --exclude "local" . build/config/includes.chroot/usr/src/ax/
mkdir build/config/includes.chroot/usr/src/build
popd >/dev/null


# -----------------
#  LOCAL BUILD STUFF
# ---------------------
if [ -e ../local/build.sh ]; then
	. ../local/build.sh
fi

# ---------------
#  BUILD IT!
# -------------
PATH="$PATH:/sbin:/usr/sbin" lb build --verbose --debug --color | tee ./build.log

popd >/dev/null

popd >/dev/null
