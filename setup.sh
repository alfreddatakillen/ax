#!/bin/bash
pushd "$(dirname $0)" >/dev/null

if [ "$(whoami)" != "root" ]; then
	echo "Must be root."
	exit 1
fi

if [ ! -d build ]; then
	mkdir build
fi
pushd build >/dev/null

if [ ! -d config ]; then
	lb config \
		-a amd64 \
		--bootappend-live "boot=live components keyboard-layouts=se" \
		--mirror-bootstrap http://ftp.se.debian.org/debian/ \
		--mirror-chroot http://ftp.se.debian.org/debian/ \
		--mirror-binary http://ftp.se.debian.org/debian/ \
		--mirror-chroot-security http://security.debian.org/ \
		--archive-areas "main contrib non-free" \
		--apt-recommends true \
		--checksums none \
		--distribution-binary bookworm \
		--iso-application "My OS" \
		--iso-publisher "user" \
		--iso-volume "(linux) (os) ($(date --rfc-3339=date))" \
		--memtest memtest86+ \
		--system live \
		--verbose \
		--win32-loader true
fi

echo "! Packages Priority standard" > config/package-lists/standard.list.chroot

 --------------------
#  WINDOW MANAGER
# ------------------
echo "xorg xinit i3" >config/package-lists/wm.list.chroot
# i3 config is in skel/.config/i3/config

# -----------------
#  TERMINAL
# ----------------------
echo "xfce4-terminal" >config/package-lists/terminal.list.chroot

# -------------------
#  NETWORKING
# -----------------
echo "iwd" >config/package-lists/wifi.list.chroot
# iwd configuration is in hooks/iwd.hook.chroot

# ----------------
#  WEB BROWSER
# ------------------
echo "chromium" >config/package-lists/webbrowser.list.chroot

# -------------------
#  GIT
# --------------
echo "git" >config/package-lists/git.list.chroot
# settings global git stuff in hooks/git.hook.chroot

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
mkdir -p build/config/includes.chroot/opt/ax
rsync -avR --exclude "build" . build/config/includes.chroot/opt/ax/
chown -R root:root build/config/includes.chroot/opt/ax
popd >/dev/null

PATH="$PATH:/sbin:/usr/sbin" lb build

popd >/dev/null
popd >/dev/null
