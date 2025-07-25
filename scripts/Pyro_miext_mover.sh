#!/run/current-system/sw/bin/bash

hife="/home/arsham/rosemary/UKL/UnpackerSystem"

# Configuration: Specify sources, targets, and flags
declare -A path_map=(
    ["$hife/mi_ext_a/product"]="$hife/product_a:content"
    ["$hife/mi_ext_a/system"]="$hife/system_a/system:content"
    ["$hife/mi_ext_a/system_ext"]="$hife/system_ext_a:content"
)

# Parse targets and flags
declare -A clear_dirs=()
declare -A content_sources=()
for source in "${!path_map[@]}"; do
    dest_entry="${path_map[$source]}"
    IFS=':' read -r dest_dir flags <<< "$dest_entry"
    
    if [[ "$dest_entry" == *":clear"* ]]; then
        clear_dirs["$dest_dir"]=1
    fi
    
    if [[ "$dest_entry" == *":content"* ]]; then
        content_sources["$source"]="$dest_dir"
    fi
done

# Clear specified directories
echo "Clearing target directories..."
for dir in "${!clear_dirs[@]}"; do
    echo "  Clearing: $dir"
    mkdir -p "$dir"
    find "$dir" -mindepth 1 -delete 2>/dev/null || true
done

# Copy and clean operations
echo "Copying files/directories..."
for source in "${!path_map[@]}"; do
    dest_entry="${path_map[$source]}"
    IFS=':' read -r dest_dir flags <<< "$dest_entry"

    if [[ ! -e "$source" ]]; then
        echo "  Error: Source '$source' missing. Skipping."
        continue
    fi

    if [[ -d "$source" && "$flags" == *"content"* ]]; then
        echo "Copying CONTENTS of: $source → $dest_dir/"
        mkdir -p "$dest_dir"
        if cp -r "$source"/. "$dest_dir"; then
            echo "  Removing source directory: $source"
            rm -rf "$source"
        else
            echo "  Error: Failed to copy contents"
            continue
        fi
        perm_path="$dest_dir"
    else
        item_name=$(basename "$source")
        dest_path="$dest_dir/$item_name"
        
        if [[ -d "$source" ]]; then
            echo "Copying DIRECTORY: $source → $dest_dir/"
            mkdir -p "$dest_dir"
            if cp -r "$source" "$dest_dir"; then
                echo "  Removing source directory: $source"
                rm -rf "$source"
            else
                echo "  Error: Directory copy failed"
                continue
            fi
        else
            echo "Copying FILE: $source → $dest_dir/"
            mkdir -p "$dest_dir"
            if cp "$source" "$dest_dir"; then
                echo "  Removing source file: $source"
                rm -f "$source"
            else
                echo "  Error: File copy failed"
                continue
            fi
        fi
        perm_path="$dest_path"
    fi

    # Set permissions
    echo "Setting permissions for: $perm_path"
    if [[ -d "$perm_path" ]]; then
        find "$perm_path" -type d -exec chmod 755 {} +
        find "$perm_path" -type f -exec chmod 644 {} +
    else
        chmod 644 "$perm_path"
    fi
done

echo "Operation complete."