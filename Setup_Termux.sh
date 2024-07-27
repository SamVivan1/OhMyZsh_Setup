# This script updates the package list, upgrades installed packages, removes unused packages, and installs Oh My Zsh, zsh-syntax-highlighting, zsh-autosuggestions, and Powerlevel10k theme with the MesloLGS NF font.
#
# It first updates the package list, upgrades installed packages, and removes unused packages.
# Then it installs Oh My Zsh, zsh-syntax-highlighting, zsh-autosuggestions, and Powerlevel10k theme.
# Finally, it installs the MesloLGS NF font and configures Oh My Zsh to use the Powerlevel10k theme and the installed plugins.

#!/bin/bash

# Memperbarui daftar paket
echo -e "\e[32mMemperbarui daftar paket...\e[0m"
apt update > /dev/null 2>&1

# Meningkatkan paket yang sudah terinstal
echo -e "\e[32mMeningkatkan paket yang sudah terinstal...\e[0m"
apt upgrade -y > /dev/null 2>&1

# Menghapus paket yang tidak lagi diperlukan
echo -e "\e[31mMenghapus paket yang tidak lagi diperlukan...\e[0m"
apt autoremove -y > /dev/null 2>&1

echo -e "\e[32mUpdate sistem selesai!\e[0m\n"

# Install git
echo -e "\e[32mInstalling git...\e[0m"
if ! command -v git &> /dev/null
then
    apt install git -y > /dev/null 2>&1
else
    echo "git sudah terinstall."
fi

# Install curl
echo -e "\e[32mInstalling curl...\e[0m"
if ! command -v curl &> /dev/null
then
    apt install curl -y > /dev/null 2>&1
else
    echo "curl sudah terinstall."
fi

# Install zsh
echo -e "\e[32mInstalling zsh...\e[0m"
if ! command -v zsh &> /dev/null
then
    apt install zsh -y > /dev/null 2>&1
else
    echo "zsh sudah terinstall."
fi

# Install OhMyZsh
echo -e "\e[32mInstalling OhMyZsh...\e[0m"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else 
    echo "Oh My Zsh sudah terinstall."
fi

# Install zsh-syntax-highlighting
echo -e "\e[32mInstalling zsh-syntax-highlighting...\e[0m"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "zsh-syntax-highlighting sudah terinstall."
fi

# Install zsh-autosuggestions
echo -e "\e[32mInstalling zsh-autosuggestions...\e[0m"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "zsh-autosuggestions sudah terinstall."
fi

# Install Powerlevel10k
echo -e "\e[32mInstalling Powerlevel10k...\e[0m"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo "Powerlevel10k sudah terinstall."
fi

# Install lsd
echo -e "\e[32mInstalling lsd...\e[0m"
if ! dpkg -s lsd >/dev/null 2>&1; then
    apt install lsd -y > /dev/null 2>&1
    echo -e "\e[32mlsd installed successfully.\e[0m"
else
    echo -e "\e[33mlsd is already installed.\e[0m"
fi

# Install zoxide
echo -e "\e[32mInstalling zoxide...\e[0m"
if ! command -v zoxide &> /dev/null
then
    apt install zoxide -y > /dev/null 2>&1
    echo -e "\e[32mzoxide has been installed successfully.\e[0m"
else
    echo -e "\e[33mzoxide is already installed. Skipping...\e[0m"
fi


# Install MesloLGS NF Font
echo -e "\e[32mInstalling font MesloLGS NF...\e[0m"

# Membuat direktori fonts jika belum ada
mkdir -p ~/.local/share/fonts

# Download font files
wget -q -P ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget -q -P ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget -q -P ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget -q -P ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

# Refresh font cache
fc-cache -f -v > /dev/null 2>&1

echo -e "\e[32mFont MesloLGS NF berhasil diinstall!\e[0m"

# Konfigurasi OhMyZsh
echo -e "\e[32mMengkonfigurasi OhMyZsh...\e[0m"

# Backup .zshrc file yang ada
cp ~/.zshrc ~/.zshrc.bak

# Mengubah tema default ke Powerlevel10k
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Menambahkan plugin yang telah diinstal
sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# Menambahkan konfigurasi untuk lsd
echo "alias ls='lsd'" >> ~/.zshrc
echo "alias l='ls -l'" >> ~/.zshrc
echo "alias la='ls -a'" >> ~/.zshrc
echo "alias lla='ls -la'" >> ~/.zshrc
echo "alias lt='ls --tree'" >> ~/.zshrc

# Menambahkan konfigurasi untuk zoxide
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

# Memuat ulang konfigurasi
if [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc
else
    echo -e "\e[33mPerubahan konfigurasi akan diterapkan saat Anda membuka sesi zsh baru.\e[0m"
fi

echo -e "\e[32mKonfigurasi OhMyZsh selesai!\e[0m"
echo -e "\e[33mSilakan restart terminal atau jalankan 'source ~/.zshrc' di dalam sesi zsh untuk menerapkan perubahan, jika tidak bisa jalankan 'zsh' terlebih dahulu.\e[0m"