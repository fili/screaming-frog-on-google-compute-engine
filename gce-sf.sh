#!/bin/bash
set -e
set -o allexport
version="9"
beta=0
reset=0
while [[ "$#" -gt 0 ]]; do case $1 in
  -b|--beta) beta=1; shift;;
  -r|--reset) reset=1; shift;;
  *) echo "Unknown parameter passed: $1"; shift; exit 0;;
esac; done
NC="\\033[0m"
GREEN="\\033[0;32m"
BLUE="\\033[1;34m"
RED="\\033[1;31m"
ORANGE="\\033[0;33m"
echo -e "${GREEN}"
echo -e "######################################################"
echo -e "#      Screaming Frog SEO Spider Install Script      #"
echo -e "#                  by Fili (${BLUE}fili.com${GREEN})                #"
echo -e "#         - SEO Expert & ex-Google engineer -        #"
echo -e "######################################################"
echo
echo -e "${RED}Installation guide:${NC}"
echo -e "${BLUE}https://searchengineland.com/how-to-run-screaming-frog-seo-spider-in-the-cloud-in-2019-317416${NC}"
echo
PLATFORM=$(grep "^NAME=" /etc/os-release |cut -d "=" -f 2 | sed -e 's/^"//' -e 's/"$//')
if [[ $PLATFORM != "Ubuntu" ]] && [[ $PLATFORM != "ubuntu" ]]; then
    echo -e "${RED}Operating System is not Ubuntu."
    echo -e "Installation aborted. Check the installation guide!${NC}"
    echo
    exit -1
fi
FREE=$(df -k --output=avail "$PWD" | tail -n1)
if [[ $FREE -lt 62914560 ]]; then               # 10G = 10*1024*1024k
    echo -e "${RED}Not enough disk space available."
    echo -e "Installation aborted. Check the installation guide!${NC}"
    echo
    exit -1
fi
if [ "$reset" -gt 0 ]; then
    echo -e "${ORANGE}Disabling SWAP.${NC}"
    sudo swapoff -a
    echo -e "${ORANGE}Removing previous Screaming Frog SEO Spider installation and data.${NC}"
    sudo rm -rf ~/.ScreamingFrogSEOSpider
    sudo rm -rf ~/.screamingfrogseospider
    ! sudo apt-get remove screamingfrogseospider -y
    rm screamingfrogseospider_*
    echo
    free -h
fi
echo
echo -e "${GREEN}[Step 1/6] Configure Screaming Frog SEO Spider settings.${NC}"
echo
cd ~/
if [[ ! -d ~/.ScreamingFrogSEOSpider ]]; then
    mkdir -p ~/.ScreamingFrogSEOSpider
fi
if [[ -f ~/.ScreamingFrogSEOSpider/licence.txt ]]; then
    echo -e "${BLUE}License found.${NC}"
    read -p "Replace? [y/n]: " LCONT
    if [[ $LCONT = 'y' ]] || [[ $LCONT = 'yes' ]] || [[ $LCONT = 'Y' ]] || [[ $LCONT = 'Yes' ]]; then
        sudo rm ~/.ScreamingFrogSEOSpider/licence.txt
        sleep 1
    fi
    echo
fi
if [[ ! -f ~/.ScreamingFrogSEOSpider/licence.txt ]]; then
    echo "To continue, you need to provide your Screaming Frog"
    echo "SEO Spider license details."
    read -p "Your license username: " USERNAME
    read -p "Your license key: " LICENSEKEY
    if [[ $USERNAME = "" ]] || [[ $USERNAME = " " ]] || [[ $LICENSEKEY = "" ]] || [[ $LICENSEKEY = " " ]]; then
        echo
        echo -e "${RED}Missing Screaming Frog SEO Spider license data."
        echo -e "Installation aborted.${NC}"
        echo
        exit -1
    fi
    touch ~/.ScreamingFrogSEOSpider/licence.txt
    echo "$USERNAME" > ~/.ScreamingFrogSEOSpider/licence.txt
    echo "$LICENSEKEY" >> ~/.ScreamingFrogSEOSpider/licence.txt
    echo
fi
if [[ -f ~/.screamingfrogseospider ]]; then
    echo -e "${BLUE}Memory allocation file found.${NC}"
    read -p "Replace? [y/n]: " MCONT
    if [[ $MCONT = 'y' ]] || [[ $MCONT = 'yes' ]] || [[ $MCONT = 'Y' ]] || [[ $MCONT = 'Yes' ]]; then
        sudo rm ~/.screamingfrogseospider
        sleep 1
    fi
    echo
fi
if [[ ! -f ~/.screamingfrogseospider ]]; then
    echo "Type a number to set memory allocation in GB, e.g. 25"
    read -p "(or leave blank defaults to 50GB): " VIRTUALMEMORY
    if [[ $VIRTUALMEMORY = "" ]] || [[ $VIRTUALMEMORY = " " ]] || [[ -n ${VIRTUALMEMORY//[0-9]/} ]]; then
        VIRTUALMEMORY="50"
    fi
    touch ~/.screamingfrogseospider
    echo "-Xmx${VIRTUALMEMORY}g" > ~/.screamingfrogseospider
    echo
fi
if [[ -f ~/.ScreamingFrogSEOSpider/spider.config ]]; then
    echo -e "${BLUE}Configuration file found.${NC}"
    read -p "Replace? [y/n]: " CCONT
    if [[ $CCONT = 'y' ]] || [[ $CCONT = 'yes' ]] || [[ $CCONT = 'Y' ]] || [[ $CCONT = 'Yes' ]]; then
        sudo rm ~/.ScreamingFrogSEOSpider/spider.config
        sleep 1
    fi
    echo
fi
if [[ ! -f ~/.ScreamingFrogSEOSpider/spider.config ]]; then
    read -p "Enable database storage mode? [y/n]: " STORAGEMODE
    if [[ $STORAGEMODE = "y" ]] || [[ $STORAGEMODE = "yes" ]] || [[ $STORAGEMODE = "Y" ]] || [[ $STORAGEMODE = "Yes" ]]; then
        STORAGEMODE="DB"
    else
        STORAGEMODE=""
    fi
    touch ~/.ScreamingFrogSEOSpider/spider.config
    echo "eula.accepted=9" > ~/.ScreamingFrogSEOSpider/spider.config
    echo "storage.mode=${STORAGEMODE}" >> ~/.ScreamingFrogSEOSpider/spider.config
    echo
fi
if [ "$beta" -gt 0 ]; then
    echo -e "${ORANGE}Enter the URL of the beta version of Screaming Frog SEO Spider.${NC}"
    read -p "URL (without spaces): " BETA_URL
    if [[ $BETA_URL = "" ]] || [[ $BETA_URL = " " ]]; then
        echo
        echo -e "${RED}No valid beta URL entered."
        echo -e "Installation aborted.${NC}"
        echo
        exit -1
    else
        URL_REGEX='^https://[^\/]*screamingfrog\.co\.uk\/.*\.deb$'
        if [[ $BETA_URL =~ $URL_REGEX ]]; then
            echo
        else
            echo
            echo -e "${RED}No valid beta URL entered."
            echo -e "Installation aborted.${NC}"
            echo
            exit -1
        fi
    fi
    echo
fi
echo -e "${GREEN}[Step 1/5] Installing dependencies.${NC}"
sudo apt-get update && sudo apt-get install dialog apt-utils -y
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt-get upgrade -y && sudo apt-get autoremove -y
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
PACKAGELIST=(
    ttf-mscorefonts-installer
    xdg-utils
    zenity
    fonts-wqy-zenhei
    libgconf-2-4
    libasound2
    libasound2-data
    libgail-common
    libgail18
    libgtk2.0-0
    libgtk2.0-bin
    libgtk2.0-common
    libnspr4
    libnss3
    libxss1
    curl
    nano
    tmux
    xvfb
)
sudo apt-get install -y "${PACKAGELIST[@]}" && sudo apt-get install -f -y
echo
echo -e "${GREEN}[Step 2/6] Configuring display for rendering.${NC}"
echo
if [ -f /etc/systemd/system/xvfb.service ]; then
    echo "Display already configured, moving on..."
else
    sudo sh -c "echo 'DISPLAY=\":99\"' >> /etc/environment"
    sudo tee -a /etc/systemd/system/xvfb.service <<EOF
[Unit]
Description=X Virtual Frame Buffer Service
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :99 -screen 0 1280x1024x24 -ac +extension GLX +render -noreset -nolisten tcp

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl enable /etc/systemd/system/xvfb.service
    sudo systemctl enable xvfb
    echo "Creating Xvfb service."
fi
is_xvfb_running=$(ps ax | grep -v grep | grep Xvfb | wc -l)
if [ "$is_xvfb_running" -eq 0 ]; then
    sudo systemctl daemon-reload
    sudo systemctl start xvfb
    echo "Starting Xvfb service."
fi
port_number=$(echo $DISPLAY)
if [ "$port_number" != :99 ]; then
    source /etc/environment
    echo "Enabling DISPLAY."
fi
echo
if [ "$beta" -gt 0 ]; then
    echo -e "${ORANGE}[Step 3/6] Downloading the BETA Screaming Frog SEO Spider installer.${NC}"
    wget "$BETA_URL"
else
    echo -e "${GREEN}[Step 3/6] Downloading the latest stable Screaming Frog SEO Spider installer.${NC}"
    wget "$(curl -sSL 'https://seo.tl/qlxr' | grep -oP '[^"]+\.deb')"
fi
echo
echo -e "${GREEN}[Step 4/6] Installing Screaming Frog SEO Spider.${NC}"
sudo dpkg -i screamingfrogseospider_*
echo
echo -e "${GREEN}[Step 5/6] Removing installers files.${NC}"
rm screamingfrogseospider_*
echo "Done."
echo
echo -e "${GREEN}[Step 6/6] Configuring SWAP.${NC}"
PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
SWAP=$(sudo swapon -s)
if [[ "$PHYMEM" -lt "50"  &&  -z "$SWAP" ]]; then
    sudo fallocate -l 50G /swapfile
    sudo chmod 600 /swapfile
    ls -lh /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo -e "/swapfile none swap sw 0 0 \\n" | sudo tee -a /etc/fstab
    echo "SWAP created."
    echo
else
    echo -e "${ORANGE}The server running with at least 50G RAM,"
    echo -e "or a SWAP file is already in place."
    echo
    echo -e "SWAP configuration skipped.${NC}"
    echo
fi
free -h
echo
echo -e "${GREEN}Installation finished. ✌${NC}"
echo
echo -e "${GREEN}Try it out!${NC}"
echo
echo -e "${GREEN}Don't forget to read the installation guide at:"
echo -e "${BLUE}https://searchengineland.com/how-to-run-screaming-frog-seo-spider-in-the-cloud-in-2019-317416${NC}"
echo
echo "######################################################"
echo "# If you have any questions or feedback or can use   #"
echo "# ex-Google Search Quality assistance with your SEO, #"
echo "# contact me at:                                     #"
echo -e "# - ${BLUE}https://fili.com/${NC}  or                            #"
echo -e "# - ${BLUE}https://seo.consulting/${NC}                          #"
echo "######################################################"
echo
