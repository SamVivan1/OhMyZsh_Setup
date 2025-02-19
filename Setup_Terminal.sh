#!/bin/bash

# Function to detect package manager
get_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

PKG_MANAGER=$(get_package_manager)

# Update package list and upgrade system
echo -e "\e[32mUpdating system packages...\e[0m"
case $PKG_MANAGER in
    "apt")
        sudo apt update > /dev/null 2>&1
        sudo apt upgrade -y > /dev/null 2>&1
        sudo apt autoremove -y > /dev/null 2>&1
        ;;
    "dnf")
        sudo dnf update -y > /dev/null 2>&1
        sudo dnf autoremove -y > /dev/null 2>&1
        ;;
    "pacman")
        sudo pacman -Syu --noconfirm > /dev/null 2>&1
        sudo pacman -Rns $(pacman -Qtdq) --noconfirm > /dev/null 2>&1 2>/dev/null || true
        ;;
    *)
        echo "Unsupported package manager"
        exit 1
        ;;
esac

echo -e "\e[32mSystem update complete!\e[0m\n"

# Install required packages
install_package() {
    local package=$1
    echo -e "\e[32mInstalling $package...\e[0m"
    
    case $PKG_MANAGER in
        "apt")
            if ! command -v $package &> /dev/null; then
                sudo apt install $package -y > /dev/null 2>&1
            else
                echo "$package already installed."
            fi
            ;;
        "dnf")
            if ! command -v $package &> /dev/null; then
                sudo dnf install $package -y > /dev/null 2>&1
            else
                echo "$package already installed."
            fi
            ;;
        "pacman")
            if ! command -v $package &> /dev/null; then
                case $package in
                    "nala")
                        echo "nala is not available on Arch Linux"
                        return
                        ;;
                    "lsd")
                        sudo pacman -S lsd --noconfirm > /dev/null 2>&1
                        ;;
                    "zoxide")
                        sudo pacman -S zoxide --noconfirm > /dev/null 2>&1
                        ;;
                    *)
                        sudo pacman -S $package --noconfirm > /dev/null 2>&1
                        ;;
                esac
            else
                echo "$package already installed."
            fi
            ;;
    esac
}

# Install required packages
for package in git curl zsh lsd zoxide fastfetch btop tmux; do
    install_package $package
done

# Install nala only for Debian/Ubuntu
if [ "$PKG_MANAGER" = "apt" ]; then
    install_package nala
fi

# Install OhMyZsh
echo -e "\e[32mInstalling OhMyZsh...\e[0m"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else 
    echo "Oh My Zsh already installed."
fi

# Install zsh-syntax-highlighting
echo -e "\e[32mInstalling zsh-syntax-highlighting...\e[0m"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "zsh-syntax-highlighting already installed."
fi

# Install zsh-autosuggestions
echo -e "\e[32mInstalling zsh-autosuggestions...\e[0m"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "zsh-autosuggestions already installed."
fi

# Install Powerlevel10k
echo -e "\e[32mInstalling Powerlevel10k...\e[0m"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo "Powerlevel10k already installed."
fi

# Install MesloLGS NF Font
echo -e "\e[32mInstalling font MesloLGS NF...\e[0m"

# Create fonts directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# Download font files
wget -q -P ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget -q -P ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget -q -P ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget -q -P ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

# Refresh font cache
fc-cache -f -v > /dev/null 2>&1

echo -e "\e[32mMesloLGS NF font installed successfully!\e[0m"

# Configure OhMyZsh
echo -e "\e[32mConfiguring OhMyZsh...\e[0m"

# Backup existing .zshrc file
cp ~/.zshrc ~/.zshrc.bak

# Change default theme to Powerlevel10k
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Add installed plugins
sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# Configure lsd
echo -e "\e[32mConfiguring lsd...\e[0m"
echo "alias ls='lsd'" >> ~/.zshrc
echo "alias l='ls -l'" >> ~/.zshrc
echo "alias la='ls -a'" >> ~/.zshrc
echo "alias lla='ls -la'" >> ~/.zshrc
echo "alias lt='ls --tree'" >> ~/.zshrc

# Configure zoxide
echo -e "\e[32mConfiguring Zoxide...\e[0m"
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

# Reload configuration
if [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc
else
    echo -e "\e[33mConfiguration changes will be applied when you open a new zsh session.\e[0m"
fi

echo -e "\e[32mOhMyZsh configuration complete!\e[0m"
echo -e "\e[33mPlease restart your terminal or run 'source ~/.zshrc' in a zsh session to apply changes. If that doesn't work, run 'zsh' first.\e[0m"