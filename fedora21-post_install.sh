#!/bin/bash

# This script intents to install some programms on a fresh fedora 21 installation
# Copyright (C) 2015  Lennard Pfennig <mrlenat@gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

echo "
    FedScript  Copyright (C) 2015  Lennard Pfennig
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions.
    For Details see <http://www.gnu.org/licenses/>

    to exit press Ctrl+c or enter 'q' at any quesiton
"

INST="sudo yum -y install"
UPDATE="sudo yum -y update"
FILE="install.sh"

show_info() {
    echo -e "\033[1;34m$@\033[0m"
}

show_error() {
    echo -e "\033[1;31m$@\033[m" 1>&2
}

write() {
    echo $@ >> $FILE
}

# this function asks you nicely if you want to install the stuff and installs it then anyway
install() { # first is programm second is description third recommend

    if [[ -z $2 ]]; then
        DES=$1
    else 
        DES=$2
    fi
    
    if [[ $3 == "y" || $3 == "Y" ]]; then
        show_info "Install" $DES"? (Y/n)"
    elif [[ $3 == "n" || $3 == "N" ]]; then
        show_info "Install" $DES"? (y/N)"
    elif [[ -z $3 ]]; then
        show_info "Install" $DES"? (y/n)"
    fi
    
    
    read REPLY
    case $REPLY in
        [Yy]*)      echo $1 >> $FILE
                    return 0;;

        [Nn]*)      return 1;;

        "")         if [[ $3 == "y" || $3 == "Y" ]]; then
                        echo $1 >> $FILE
                    elif [[ -z $3 ]]; then
                        echo "try again: "
                        install "$1" "$2"
                    fi;;

        "q")        exit 0;;

        *)          echo "try again: "
                    install "$1" "$2" "$3";;
    esac

    
}


write 

if [[ -e install.sh ]]; then
    show_error "Ein install.sh file ist bereits da. Neues file, überschreiben, ende? (n,u,e)"
    read REPLY
    case $REPLY in
        "n") echo "neuer name:"
                read FILE;;
        "u") echo "" > $FILE;;
        "e") exit 0;;
        *) "ja is klar ..."
            exit 123;;
    esac
fi

# Update the packages first and install the GPG keys
write $UPDATE

install "$INST yum-plugin-fastestmirror" "prog to find mirrors fast" "y"



install "sudo rpm -ivh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-21.noarch.rpm" "rpm-fusion free" "y" 
RPM=$?
install "sudo rpm -ivh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-21.noarch.rpm" "rpm-fusion nonfree" "y"

if [[ $? == 0 || $RPM  == 0 ]]; then
    write $UPDATE
fi


# Install VLC - for watching videos without worrying about the file formats
install "$INST vlc" "vlc" "Y"
# Install Unrar - for extracting RAR file archives
install "$INST unrar unzip" "zip-progs" "y"

# Install Grip - CD-ripper with database lookup/submission to share track information over the net, supports OGG and FLAC and adding ID3v1/v2 to MP3s.
install "$INST grip cdparanoia" ""

# GStreamer non-free plugins
install "$INST phonon-backend-gstreamer gstreamer-plugins-base gstreamer1-libav gstreamer1-plugins-base-tools gstreamer{1,}-{plugin-crystalhd,ffmpeg,plugins-{base,good,ugly,bad{,-free,-nonfree,-freeworld,-extras}}} libmpg123 lame-libs" "gstreamer" "y"

# FFMpeg
install "$INST ffmpeg ffmpeg-libs" "ffmpeg"

# DVD playback
install "$INST libdvdread libdvdnav lsdvd libdvdcss" "codecs for DVD" "y"

#zsh shell and grml config (which is kinda nice)
install "$INST zsh" "zsh and grml config" "y"

if [[ $? == 0 ]]; then
    cat >> $FILE <<HERE
chsh -s /usr/bin/zsh $USERNAME
wget -O ~/.zshrc http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
wget -O ~/.zshrc.local  http://git.grml.org/f/grml-etc-core/etc/skel/.zshrc

HERE
fi

# flash and sublime download
if [ $(uname -i) = 'i386' ]; then
    install "wget -O /tmp/subl http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3083.tar.bz2" "Sublime Text Editor 3" "y"
    RET=$?
elif [ $(uname -i) = 'x86_64' ]; then
    install "wget -O /tmp/subl http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3083_x64.tar.bz2" "Sublime Text Editor 3" "y"
    RET=$?
fi

# sublime install
if [[ $RET == 0 ]]; then
    cat >> $FILE <<HERE
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

HERE

fi
# flash install

if [ $(uname -i) = 'i386' ]; then
    install "sudo rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-i386-1.0-1.noarch.rpm" "Adobe flash" "y"
    RET=$?
elif [ $(uname -i) = 'x86_64' ]; then
    install "sudo rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm" "Adobe flash" "y"
    RET=$?
fi

if [[ $RET == 0 ]]; then
    write sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
    write $INST flash-plugin
fi

#latex
install "$INST texlive" "latex. Its good for writing u know?" "y"
if [[ $? == 0 ]]; then
    write "$INST texlive-latex"
    write "$INST texlive-biblatex"
    write "$INST texlive-scheme-basic"
    write "$INST texlive-scheme-full"
    write "$INST texlive-collection-basic"
    write "$INST texlive-collection-langgerman"
    write "$INST texlive-collection-langenglish"
    install "$INST texstduio" "editor for latex files" "y"
fi

#skype
install "$INST skype" "skype" "n"

#dropbox
install "$INST dropbox" "dropbox" "n"

#thunderbird
install "$INST thunderbird" "thunderbird mail client" "n"
if [[ $? ]]; then
    install "$INST thunderbird-lightning-gdata" "google calender for thunderbird" "y"
    install "$INST thunderbird-lightning" "calender for thunderbird" "y"
    install "$INST thunderbird-enigmail" "gpg for thunderbird" "y"
fi

# addblock for firefox
install "wget -O /tmp/adblock.xpi https://addons.mozilla.org/firefox/downloads/latest/1865/addon-1865-latest.xpi" "adblock against Adverts" "y"
if [[ $? == 0 ]]; then
    write firefox /tmp/adblock.xpi
fi


# dat mopped starten:

chmod +x $FILE
./$FILE