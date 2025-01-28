#!/bin/bash

for cmd in unrar curl flatpak; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it and try again."
        exit 1
    fi
done

echo "Creating directory ~/Games..."
mkdir -p ~/Games || { echo "Failed to create ~/Games directory."; exit 1; }

echo "Checking if Bottles is installed..."
if ! flatpak list --app | grep -q "com.usebottles.bottles"; then
    echo "Installing Bottles..."
    if ! flatpak install -y flathub com.usebottles.bottles; then
        echo "Error: Failed to install Bottles."
        exit 1
    fi
else
    echo "Bottles is already installed."
fi

# echo "Downloading PUBG .rar file..."
# if ! curl -o ~/Downloads/Pubg.rar https://pixeldrain.com/api/file/w1iGoHs3; then
#     echo "Error: Failed to download PUBG .rar file."
#     exit 1
# fi

echo "Extracting the .rar file..."
if ! unrar x ~/Downloads/Pubg.rar ~/Games; then
    echo "Error: Failed to extract PUBG .rar file."
    exit 1
fi

echo "Creating new Bottle 'PUBG_OG' with win64 architecture and gaming environment..."
if ! flatpak run --command=bottles-cli com.usebottles.bottles new --bottle-name PUBG_OG --arch win64 --environment gaming; then
    echo "Error: Failed to create the 'PUBG_OG' bottle."
    exit 1
fi

echo "Configuring the bottle to use Windows 11 and setting the working directory..."
if ! flatpak run --command=bottles-cli com.usebottles.bottles edit -b PUBG_OG --win win11 || \
   ! flatpak run --command=bottles-cli com.usebottles.bottles edit -b PUBG_OG --env-var HOME=/home/$USER/Games/PUBG_11_OCTOBER_2017; then
    echo "Error: Failed to configure the 'PUBG_OG' bottle."
    exit 1
fi

echo "Adding the game to the 'PUBG_OG' bottle..."
if ! flatpak run --command=bottles-cli com.usebottles.bottles add -b PUBG_OG -n ogbg -p ~/Games/PUBG_11_OCTOBER_2017/TslGame/Binaries/Win64/OGBATTLEGROUNDS.bat; then
    echo "Error: Failed to add the game to the bottle."
    exit 1
fi

echo "Everything succeeded! You can now open Bottles and play the game :)"
