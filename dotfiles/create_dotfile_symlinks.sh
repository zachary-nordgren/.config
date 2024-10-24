#!/bin/bash

# Configuration
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$CONFIG_DIR/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Error: $DOTFILES_DIR does not exist!"
  echo "Please make sure your dotfiles are in place before running this script."
  exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo "Created backup directory: $BACKUP_DIR"

# Function to create a symlink
create_symlink() {
  local source="$1"
  local target="$2"

  # If target already exists
  if [ -e "$target" ] || [ -L "$target" ]; then
    # Create backup
    if [ -f "$target" ] || [ -L "$target" ]; then
      echo "Backing up existing file: $target"
      cp -P "$target" "$BACKUP_DIR/$(basename "$target").bak"
    fi

    echo "Removing existing file: $target"
    rm -f "$target"
  fi

  # Create symlink
  ln -s "$source" "$target"
  echo "Created symlink: $target -> $source"
}

echo "Creating symlinks for dotfiles..."
echo "Any existing files will be backed up to: $BACKUP_DIR"

# Find all files in the dotfiles directory and create symlinks
for file in "$DOTFILES_DIR"/*; do
  if [ -f "$file" ]; then
    # Get just the filename
    filename=$(basename "$file")
    # Create the dotfile name
    dotfile="$HOME/.$filename"

    create_symlink "$file" "$dotfile"
  fi
done

# Check if any backups were actually created
if [ -z "$(ls -A "$BACKUP_DIR")" ]; then
  echo "No existing files needed backup, removing empty backup directory"
  rmdir "$BACKUP_DIR"
else
  echo -e "\nBackups of existing files were created in: $BACKUP_DIR"
fi

echo -e "\nSymlink creation complete!"
echo "Your dotfiles from $DOTFILES_DIR are now linked in your home directory"
