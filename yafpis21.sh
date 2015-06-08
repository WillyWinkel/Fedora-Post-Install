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

INST="dnf -y install"
UPDATE="dnf -y update"
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

# This function is a wrapper to dnf
# arguments: prog description suggestion<-(y/n)
# e.g.: you want to install pidgin: instYum pidgin "messenger for jabber" y
instYum() { 
    install dnf "$1" "$2" "$3" "$4"
}

instOther() {
    install other "$1" "$2" "$3" "$4"
}

# this is the hidden install function
# just use the wrapper
# it might look horrible but this is just bash.
install() { 

    if [[ -z $3 ]]; then
        DES=$2
    else 
        DES=$3
    fi
    
    if [[ $4 == "y" || $4 == "Y" ]]; then
        show_info "Install" $DES"? (Y/n)"
    elif [[ $4 == "n" || $4 == "N" ]]; then
        show_info "Install" $DES"? (y/N)"
    elif [[ -z $4 ]]; then
        show_info "Install" $DES"? (y/n)"
    fi
    
    read REPLY
    case $REPLY in
        [Yy]*)      if [[ $1 == "dnf" ]]; then
                        echo $INST $2 >> $FILE
                    elif [[ $1 == "other" ]]; then
                        echo $2 >> $FILE
                    else
                        exit 33
                    fi 
                    return 0;;

        [Nn]*)      return 1;;

        "")         if [[ $4 == "y" || $4 == "Y" ]]; then
                        if [[ $1 == "dnf" ]]; then
                            echo $INST $2 >> $FILE
                        elif [[ $1 == "other" ]]; then
                            echo $2 >> $FILE
                        else
                            exit 33
                        fi
                        return 0
                    elif [[ $4 == "n" || $4 == "N" ]]; then
                        return 1
                    elif [[ -z $4 ]]; then
                        echo "try again: "
                        install "$1" "$2" "$3"
                    fi;;

        "q")        rm $FILE
                    exit 0;;

        *)          echo "try again: "
                    install "$1" "$2" "$3" "$4";;
    esac

    
}


# checks if there is already an install.sh file
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
    chmod 744 $FILE     # security
fi

#       ----------------------------
#
#       From here on starts the fun.
#
#       ---------------------------

# Update the packages first and install the GPG keys
write $UPDATE

# instYum yum-plugin-fastestmirror "prog to find mirrors fast" y # questionable

instOther "rpm -ivh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-21.noarch.rpm" "rpm-fusion free (for music and stuff)" "y"
RPM=$?
instOther "rpm -ivh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-21.noarch.rpm" "rpm-fusion nonfree (for music and stuff as well)" "y"

if [[ $? == 0 || $RPM  == 0 ]]; then
    write $UPDATE
fi


# Install VLC - for watching videos without worrying about the file formats
instYum vlc "vlc" Y
# Install Unrar - for extracting RAR file archives
instYum "unrar unzip" "zip-progs" "y"

# Install Grip - CD-ripper with database lookup/submission to share track information over the net, supports OGG and FLAC and adding ID3v1/v2 to MP3s.
instYum "grip cdparanoia" "ripping progs" "y"

# GStreamer non-free plugins
instYum "phonon-backend-gstreamer gstreamer-plugins-base gstreamer1-libav gstreamer1-plugins-base-tools gstreamer{1,}-{plugin-crystalhd,ffmpeg,plugins-{base,good,ugly,bad{,-free,-nonfree,-freeworld,-extras}}} libmpg123 lame-libs" "gstreamer, for watching movies and hearing music" "y"

# FFMpeg
instYum "ffmpeg ffmpeg-libs" "ffmpeg (converting media files)" "y"

# DVD playback
instYum "libdvdread libdvdnav lsdvd libdvdcss" "codecs for DVD" "y"

#zsh shell and grml config (which is kinda nice)
instYum "zsh" "zsh (terminal) and grml config (cool)" "y"

if [[ $? == 0 ]]; then
cat >> $FILE <<HERE
chsh -s /usr/bin/zsh $USERNAME
wget -O ~/.zshrc http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
wget -O ~/.zshrc.local  http://git.grml.org/f/grml-etc-core/etc/skel/.zshrc

HERE
fi

# flash and sublime download
if [ $(uname -i) = 'i386' ]; then
    instOther "wget -O /tmp/subl http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3083.tar.bz2" "Sublime Text Editor 3" "y"
    RET=$?
elif [ $(uname -i) = 'x86_64' ]; then
    instOther "wget -O /tmp/subl http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3083_x64.tar.bz2" "Sublime Text Editor 3" "y"
    RET=$?
fi

# sublime install
if [[ $RET == 0 ]]; then
cat >> $FILE <<HERE
tar xf /tmp/subl
mv sublime_text_3 /opt/
ln -sf /opt/sublime_text_3/sublime_text /usr/bin/subl
ln -sf /opt/sublime_text_3/sublime_text /usr/bin/sublime

echo "[Desktop Entry]
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

cp -r /opt/sublime_text_3/Icon/16x16/* /usr/share/icons/hicolor/16x16/apps
cp -r /opt/sublime_text_3/Icon/32x32/* /usr/share/icons/hicolor/32x32/apps
cp -r /opt/sublime_text_3/Icon/48x48/* /usr/share/icons/hicolor/48x48/apps
cp -r /opt/sublime_text_3/Icon/128x128/* /usr/share/icons/hicolor/128x128/apps
cp -r /opt/sublime_text_3/Icon/256x256/* /usr/share/icons/hicolor/256x256/apps
gtk-update-icon-cache /usr/share/icons/hicolor

HERE

fi
# flash install

if [ $(uname -i) = 'i386' ]; then
    instOther "rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-i386-1.0-1.noarch.rpm" "Adobe flash" "y"
    RET=$?
elif [ $(uname -i) = 'x86_64' ]; then
    instOther "rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm" "Adobe flash" "y"
    RET=$?
fi

if [[ $RET == 0 ]]; then
    write rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
    write $INST flash-plugin
fi

#latex
instYum "texlive" "latex. Its good for writing u know?" "y"
if [[ $? == 0 ]]; then
    write "$INST texlive-latex"
    write "$INST texlive-biblatex"
    write "$INST texlive-scheme-basic"
    write "$INST texlive-scheme-full"
    write "$INST texlive-collection-basic"
    write "$INST texlive-collection-langgerman"
    write "$INST texlive-collection-langenglish"
    instYum "texstduio" "editor for latex files" "y"
fi

#skype
instYum "skype" "skype" "n"

#dropbox
instYum "dropbox" "dropbox" "n"

#thunderbird
instYum "thunderbird" "thunderbird mail client" "n"
if [[ $? == 0 ]]; then
    instYum "thunderbird-lightning-gdata" "google calender for thunderbird" "y"
    instYum "thunderbird-lightning" "calender for thunderbird" "y"
    instYum "thunderbird-enigmail" "gpg for thunderbird (sichere ende zu ende verschlüsselung, google gpg)" "y"
fi


instYum gnome-tweak-tool "advanced configuration for gnome" y
instYum @mate-desktop "Mate Desktop" n
instYum @kde-desktop "KDE Desktop" n
instYum @xfce-desktop "XFCE Desktop" n
instYum @lxde-desktop "lxde Desktop" n
instYum @cinnamon-desktop "Cinnamon Desktop" n
instYum VirtualBox "VirtualBox" n
instYum gnome-music "Gnome Music Player" n
instYum qbittorrent "qbittorrent client" n
instYum steam "Steam for Linux :)" n

instYum "nodejs rubygem-compass" "Popcorn Streaming cinnema" n

if [[ $? == 0 ]]; then
    if [ $(uname -i) = 'i386' ]; then
        write "rpm -ivh ftp://ftp.pbone.net/mirror/ftp.sourceforge.net/pub/sourceforge/p/po/postinstaller/fedora/releases/21/i386/popcorntime-0.3.5.2-1.fc21.i686.rpm"
    elif [ $(uname -i) = 'x86_64' ]; then
        write "rpm -ivh ftp://ftp.pbone.net/mirror/ftp.sourceforge.net/pub/sourceforge/p/po/postinstaller/fedora/releases/21/x86_64/popcorntime-0.3.5.2-1.fc21.x86_64.rpm"
    fi
fi


# addblock for firefox
instOther "wget -O /tmp/adblock.xpi https://addons.mozilla.org/firefox/downloads/latest/1865/addon-1865-latest.xpi" "adblock against Adverts" "y"
if [[ $? == 0 ]]; then
    write firefox /tmp/adblock.xpi
fi


# dat mopped starten:
write "rm $FILE"
chmod +x $FILE
./$FILE

rm $0
