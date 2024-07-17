#!/bin/bash

# Memperbarui daftar paket
echo -e "\e[32mMemperbarui daftar paket...\e[0m"
sudo apt update > /dev/null 2>&1

# Meningkatkan paket yang sudah terinstal
echo -e "\e[32mMeningkatkan paket yang sudah terinstal...\e[0m"
sudo apt upgrade -y > /dev/null 2>&1

# Menghapus paket yang tidak lagi diperlukan
echo -e "\e[31mMenghapus paket yang tidak lagi diperlukan...\e[0m"
sudo apt autoremove -y > /dev/null 2>&1

echo -e "\e[32mUpdate sistem selesai!\e[0m\n"

# Install OhMyZsh
echo -e "\e[32mMenginstall OhMyZsh...\e[0m"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh sudah terinstall."
fi

# Install zsh-syntax-highlighting
echo -e "\e[32mMenginstall zsh-syntax-highlighting...\e[0m"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "zsh-syntax-highlighting sudah terinstall."
fi

# Install zsh-autosuggestions
echo -e "\e[32mMenginstall zsh-autosuggestions...\e[0m"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "zsh-autosuggestions sudah terinstall."
fi

# Install Powerlevel10k
echo -e "\e[32mMenginstall Powerlevel10k...\e[0m"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo "Powerlevel10k sudah terinstall."
fi

# Install MesloLGS NF Font
echo -e "\e[32mMenginstall font MesloLGS NF...\e[0m"

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

# Memuat ulang konfigurasi
if [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc
else
    echo -e "\e[33mPerubahan konfigurasi akan diterapkan saat Anda membuka sesi zsh baru.\e[0m"
fi

echo -e "\e[32mKonfigurasi OhMyZsh selesai!\e[0m"
echo -e "\e[33mSilakan restart terminal atau jalankan 'source ~/.zshrc' di dalam sesi zsh untuk menerapkan perubahan.\e[0m"