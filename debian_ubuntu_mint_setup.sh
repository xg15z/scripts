#!/bin/bash
# Run this script as root

# Change the variables below to customize
INSTALLATION_USER='mark'
SCALA_URL='http://downloads.lightbend.com/scala/2.12.1/scala-2.12.1.tgz'
GOLANG_URL='https://storage.googleapis.com/golang/go1.7.5.linux-amd64.tar.gz'
JAVA_VERSION=8
PYTHON3_VERSION=3.6.0
PYTHON2_VERSION=2.7.13

# Update the system before installing the programs
apt update
yes | apt upgrade
yes | apt dist-upgrade

# Install UNIX tools
yes | apt install sudo cups printer-driver-cups-pdf gnupg2 dirmngr apt-transport-https
systemctl stop cups-browsed.service
systemctl disable cups-browsed.service

# Install multimedia tools
yes | apt install amarok flac vorbis-tools lame libmp3lame0 vlc okular okular-extra-backends soundconverter easytag easytag-nautilus

# Install desktop applications
yes | apt install dropbox gedit gnucash shutter filezilla

# Install command-line applications
yes | apt install git git-doc git-man pandoc openssh-server tmux vim-nox screen

# Install fonts
yes | apt install fonts-inconsolata

# Install Korean fonts and input tools
yes | apt install fonts-nanum uim uim-gtk3 uim-byeoru

# Install LaTeX tools
yes | apt install texlive-full kile

# Install Java
yes | apt install openjdk-$JAVA_VERSION-jre openjdk-$JAVA_VERSION-jre-headless openjdk-$JAVA_VERSION-jdk openjdk-$JAVA_VERSION-jdk-headless
echo "export JAVA_HOME=/usr/lib/jvm/java-$JAVA_VERSION-openjdk-amd64" >> /home/$INSTALLATION_USER/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin'
touch /usr/release

# Install Python. See https://github.com/yyuu/pyenv
yes | apt install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils libfreetype*-dev libpng-dev pkg-config python-tk python3-tk tk-dev libjpeg-dev libtiff*-dev 
git clone https://github.com/yyuu/pyenv.git /home/$INSTALLATION_USER/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/$INSTALLATION_USER/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/$INSTALLATION_USER/.bashrc
echo 'eval "$(pyenv init -)"' >> /home/$INSTALLATION_USER/.bashrc
chown -Rv $INSTALLATION_USER /home/$INSTALLATION_USER/.pyenv
# Run pyenv install and pyenv local as $INSTALLATION_USER, rather than root
sudo -H -u $INSTALLATION_USER /home/$INSTALLATION_USER/.pyenv/bin/pyenv install $PYTHON3_VERSION
sudo -H -u $INSTALLATION_USER /home/$INSTALLATION_USER/.pyenv/bin/pyenv install $PYTHON2_VERSION
sudo -H -u $INSTALLATION_USER /home/$INSTALLATION_USER/.pyenv/bin/pyenv local $PYTHON3_VERSION

# Install Scala
# Install scala-sbt. See http://www.scala-sbt.org/download.html
echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
yes | apt install sbt
# Install scala. See https://www.scala-lang.org/download/install.html
wget -O /home/$INSTALLATION_USER/Downloads/scala.tgz $SCALA_URL
tar -xf /home/$INSTALLATION_USER/Downloads/scala.tgz -C /usr/local
mv /usr/local/scala* /usr/local/scala
rm -rf /home/$INSTALLATION_USER/Downloads/scala.tgz
echo 'export SCALA_HOME=/usr/local/scala' >> /home/$INSTALLATION_USER/.bashrc
echo 'export PATH=$PATH:$SCALA_HOME/bin' >> /home/$INSTALLATION_USER/.bashrc

# Install Golang. See https://golang.org/doc/install
wget -O /home/$INSTALLATION_USER/Downloads/golang.tar.gz $GOLANG_URL
tar -xf /home/$INSTALLATION_USER/Downloads/golang.tar.gz -C /usr/local
rm -rf /home/$INSTALLATION_USER/Downloads/golang.tar.gz
echo 'export GOROOT=/usr/local/go' >> /home/$INSTALLATION_USER/.bashrc
echo 'export PATH=$PATH:$GOROOT/bin' >> /home/$INSTALLATION_USER/.bashrc
