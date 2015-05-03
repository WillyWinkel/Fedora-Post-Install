
sudo yum -y update
sudo yum -y install yum-plugin-fastestmirror
sudo rpm -ivh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-21.noarch.rpm
sudo rpm -ivh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-21.noarch.rpm
sudo yum -y update
sudo yum -y install vlc
sudo yum -y install unrar unzip
sudo yum -y install grip cdparanoia
sudo yum -y install phonon-backend-gstreamer gstreamer-plugins-base gstreamer1-libav gstreamer1-plugins-base-tools gstreamer{1,}-{plugin-crystalhd,ffmpeg,plugins-{base,good,ugly,bad{,-free,-nonfree,-freeworld,-extras}}} libmpg123 lame-libs
sudo yum -y install ffmpeg ffmpeg-libs
sudo yum -y install libdvdread libdvdnav lsdvd libdvdcss
sudo yum -y install zsh
chsh -s /usr/bin/zsh bfam
wget -O ~/.zshrc http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
wget -O ~/.zshrc.local  http://git.grml.org/f/grml-etc-core/etc/skel/.zshrc

wget -O /tmp/subl http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3083_x64.tar.bz2
tar xf /tmp/subl
sudo mv sublime_text_3 /opt/
sudo ln -sf /opt/sublime_text_3/sublime_text /usr/bin/subl
sudo ln -sf /opt/sublime_text_3/sublime_text /usr/bin/sublime

sudo echo "[Desktop Entry]
Version=3
Name=Sublime Text 3
GenericName=Text Editor
 
Exec=sublime
Terminal=false
Icon=sublime-text
Type=Application
Categories=TextEditor;IDE;Development
X-GNOME-FullName=Sublime Text 3
[NewWindow Shortcut Group]
Name=New Window
Exec=sublime -n" >> /usr/share/applications/sublime-text.desktop

sudo cp -r /opt/sublime_text_3/Icon/16x16/* /usr/share/icons/hicolor/16x16/apps
sudo cp -r /opt/sublime_text_3/Icon/32x32/* /usr/share/icons/hicolor/32x32/apps
sudo cp -r /opt/sublime_text_3/Icon/48x48/* /usr/share/icons/hicolor/48x48/apps
sudo cp -r /opt/sublime_text_3/Icon/128x128/* /usr/share/icons/hicolor/128x128/apps
sudo cp -r /opt/sublime_text_3/Icon/256x256/* /usr/share/icons/hicolor/256x256/apps
sudo gtk-update-icon-cache /usr/share/icons/hicolor

sudo rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
sudo yum -y install flash-plugin
wget -O /tmp/adblock.xpi https://addons.mozilla.org/firefox/downloads/latest/1865/addon-1865-latest.xpi
firefox /tmp/adblock.xpi
