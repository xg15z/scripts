#!/bin/bash
# Run this script as root

# Change the variables below to customize
INSTALLATION_USER='mark'
SCALA_URL='http://downloads.lightbend.com/scala/2.12.1/scala-2.12.1.tgz'
GOLANG_URL='https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz'
FIREFOX_NIGHTLY_URL='https://archive.mozilla.org/pub/firefox/nightly/latest-mozilla-central/firefox-53.0a1.en-US.linux-x86_64.tar.bz2'
JAVA_VERSION=8
RUBY_VERSION=2.3.3
PYTHON3_VERSION=3.6.0
PYTHON2_VERSION=2.7.13
NODE_VERSION=6.9.2

# Update the system before installing the programs
apt update
yes | apt upgrade
yes | apt dist-upgrade

# Install multimedia tools
yes | apt install amarok flac vorbis-tools lame libmp3lame0 vlc okular okular-extra-backends soundconverter easytag easytag-nautilus

# Install desktop applications
yes | apt install dropbox gedit gnucash shutter filezilla

# Install command-line applications
yes | apt install git git-doc git-man pandoc openssh-server tmux vim-nox

# Install Korean fonts and input tools
yes | apt install fonts-nanum ibus-hangul

# Install LaTeX tools
yes | apt install texlive-full kile

# Install Java
yes | apt install openjdk-$JAVA_VERSION-jre openjdk-$JAVA_VERSION-jre-headless openjdk-$JAVA_VERSION-jdk openjdk-$JAVA_VERSION-jdk-headless

# Install Racket
yes | apt install racket

# Install Python. See https://github.com/yyuu/pyenv
yes | apt install libbz2-dev
git clone https://github.com/yyuu/pyenv.git /home/$INSTALLATION_USER/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/$INSTALLATION_USER/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/$INSTALLATION_USER/.bashrc
echo 'eval "$(pyenv init -)"' >> /home/$INSTALLATION_USER/.bashrc
chown -Rv $INSTALLATION_USER /home/$INSTALLATION_USER/.pyenv
# Run pyenv install and pyenv local as $INSTALLATION_USER, rather than root
sudo -H -u $INSTALLATION_USER /home/$INSTALLATION_USER/.pyenv/bin/pyenv install $PYTHON3_VERSION
sudo -H -u $INSTALLATION_USER /home/$INSTALLATION_USER/.pyenv/bin/pyenv install $PYTHON2_VERSION
sudo -H -u $INSTALLATION_USER /home/$INSTALLATION_USER/.pyenv/bin/pyenv local $PYTHON3_VERSION

# Install Ruby. See https://github.com/rbenv/ruby-build/wiki
yes | apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libsqlite3-dev ruby-dev zlib1g-dev
git clone https://github.com/rbenv/rbenv.git /home/$INSTALLATION_USER/.rbenv
cd /home/$INSTALLATION_USER/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/$INSTALLATION_USER/.bashrc
echo 'eval "$(rbenv init -)"' >> /home/$INSTALLATION_USER/.bashrc
git clone https://github.com/rbenv/ruby-build.git /home/$INSTALLATION_USER/.rbenv/plugins/ruby-build
chown -Rv $INSTALLATION_USER /home/$INSTALLATION_USER/.rbenv
# Run rbenv install and rbenv local as $INSTALLATION_USER, rather than root
sudo -H -u $INSTALLATION_USER /home/$INSTALLATION_USER/.rbenv/bin/rbenv install $RUBY_VERSION
sudo -H -u $INSTALLATION_USER /home/$INSTALLATION_USER/.rbenv/bin/rbenv local $RUBY_VERSION

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

# Instal Node.js. See https://github.com/creationix/nvm
git clone https://github.com/creationix/nvm /home/$INSTALLATION_USER/.nvm
echo 'export NVM_DIR=$HOME/.nvm' >> /home/$INSTALLATION_USER/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /home/$INSTALLATION_USER/.bashrc
chown -Rv $INSTALLATION_USER /home/$INSTALLATION_USER/.nvm
# Make nvmscript.sh, which is to be run on $INSTALLATION_USER's shell.
# Double quotation marks are used here to load the values of $ variables,
# instead of the litral strings.
echo "source /home/$INSTALLATION_USER/.bashrc" >> /home/$INSTALLATION_USER/nvmscript.sh
echo "nvm install $NODE_VERSION" >> /home/$INSTALLATION_USER/nvmscript.sh
echo "nvm use $NODE_VERSION" >> /home/$INSTALLATION_USER/nvmscript.sh
chmod 700 /home/$INSTALLATION_USER/nvmscript.sh
chown $INSTALLATION_USER /home/$INSTALLATION_USER/nvmscript.sh
# Run nvmscript.sh on $INSTALLATION_USER's shell and delete the script afterwards
su $INSTALLATION_USER -c /home/$INSTALLATION_USER/nvmscript.sh
rm -f /home/$INSTALLATION_USER/nvmscript.sh

# Install Firefox Nightly
wget -O /home/$INSTALLATION_USER/Downloads/nightly.tar.bz2 $FIREFOX_NIGHTLY_URL
tar -xf /home/$INSTALLATION_USER/Downloads/nightly.tar.bz2 -C /home/$INSTALLATION_USER/
rm -rf /home/$INSTALLATION_USER/Downloads/nightly.tar.bz2
mv /home/$INSTALLATION_USER/firefox* /home/$INSTALLATION_USER/.nightly
mkdir /home/$INSTALLATION_USER/bin
ln -s /home/$INSTALLATION_USER/.nightly/firefox /home/$INSTALLATION_USER/bin/nightly
chown -Rv $INSTALLATION_USER /home/$INSTALLATION_USER/.nightly
chown -Rv $INSTALLATION_USER /home/$INSTALLATION_USER/bin
chmod 700 /home/$INSTALLATION_USER/bin/nightly
echo 'export PATH=$PATH:$HOME/bin' >> /home/$INSTALLATION_USER/.bashrc
