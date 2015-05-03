# Update the packages first and install the GPG keys
sudo yum -y update

sudo rpm -ivh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-21.noarch.rpm
sudo rpm -ivh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-21.noarch.rpm

sudo yum -y install checkpolicy

# Install VLC - for watching videos without worrying about the file formats
sudo yum -y install vlc

# Install Unrar - for extracting RAR file archives
sudo yum -y install unrar

# Install Grip - CD-ripper with database lookup/submission to share track information over the net, supports OGG and FLAC and adding ID3v1/v2 to MP3s.
sudo yum -y install grip cdparanoia

# GStreamer non-free plugins
sudo yum -y install gstreamer-plugins-bad gstreamer-plugins-ugly gstreamer-ffmpeg phonon-backend-gstreamer gstreamer-plugins-base

# FFMpeg
sudo yum -y install ffmpeg ffmpeg-libs

# DVD playback
sudo yum -y install libdvdread libdvdnav lsdvd

# addblock for firefox
wget -O /tmp/adblock.xpi https://addons.mozilla.org/firefox/downloads/latest/1865/addon-1865-latest.xpi
firefox /tmp/adblock.xpi
