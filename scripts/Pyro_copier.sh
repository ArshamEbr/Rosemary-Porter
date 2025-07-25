#!/run/current-system/sw/bin/bash

haha="/home/arsham/rosemary/UKL/UnpackerSystem"

# Configuration: Sources, targets, and flags
declare -A path_map=(
    # EXAMPLES
#    ["/path/to/source/file1"]="/target/directory1"                        # Regular file copy
#    ["/path/to/source/folder1"]="/target/directory2:clear"                # Clear target before copying directory
#    ["/path/to/source/folder2"]="/target/directory3:content"              # Copy folder CONTENTS (not the folder itself)
#    ["/path/to/source/folder3"]="/target/directory4:clear:content"        # Clear target & copy folder contents
#    ["/path/to/source/folder4"]="/target/directory5:clear:content:valid"  # Create destination if it doesn't exist

    ["product/etc/device_features"]="$haha/product_a/etc/device_features:clear:content" # Needed based on variant
    ["product/etc/displayconfig"]="$haha/product_a/etc/displayconfig:clear:content"     # Needed based on variant

    ["product/priv-app/Viper4AndroidFX"]="$haha/product_a/priv-app/Viper4AndroidFX:clear:content:valid" # Viper Soundfx
    ["product/etc/permissions/privapp-permissions-dsps.xml"]="$haha/product_a/etc/permissions"          # Viperfx perms
    ["system/etc/audio_effects.conf"]="$haha/system_a/system/etc"                                       # Viperfx and Dolby configs

    ["product/Moverlay"]="$haha/product_a/overlay:content"  # MIUI / HOS1
#    ["product/Hoverlay"]="$haha/product_a/overlay:content" # HOS1.1 / HOS2

    ["product/priv-app/MiuiCamera"]="$haha/product_a/priv-app/MiuiCamera:clear:content:valid"     # Stock cam Miui/hos1
#    ["product/priv-app/MiuiCamerauni"]="$haha/product_a/priv-app/MiuiCamera:clear:content"       # Universal cam for hos2
#    ["product/app/MiuiBiometric"]="$haha/product_a/app/MiuiBiometric:clear:content"              # face unlock
    ["product/app/LatinImeGoogle"]="$haha/product_a/app/LatinImeGoogle:clear:content:valid"       # Gboard

    # Pyro Icons
    ["product/media/theme/default/com.android.systemui"]="$haha/product_a/media/theme/default" # Custom icons, A BIG NO FOR HOS2!

    # CN
#    ["product/CN"]="$haha/product_a:content"
#    ["product/TW"]="$haha/product_a:content"
#    ["system_ext/priv-app"]="$haha/system_ext_a/priv-app:content"
#    ["product/app/MIUIThemeManager"]="$haha/product_a/app/MIUIThemeManager:clear:content"

    # HOS2 
#    ["system_ext/Apex"]="$haha/system_ext_a/apex:content"

    # Touchpad
#    ["system/usr"]="$haha/system_a/system/usr:content"
)

# Prompt configuration
declare -A prompt_messages=(
#    ["product/CN"]="Install Hyper CN Dialer/MMS if it's a Global A15 Base?"
#    ["product/TW"]="Install Hyper TW Dialer/MMS if it's a Global A15 Base?"
#    ["system_ext/priv-app"]="Add CN AuthManager if it's a Global A15 Base??"
#    ["product/MIUIThemeManager"]="Add CN ThemeManager if it's a Global A15 Base??"
)

# Function to get fallback destination path
get_fallback_path() {
    local original_path="$1"
    
    # Replace _a suffixes with no suffix for fallback
    local fallback_path
    fallback_path=$(echo "$original_path" | sed 's|/product_a\b|/product|g; s|/system_a\b|/system|g; s|/system_ext_a\b|/system_ext|g')
    
    echo "$fallback_path"
}

# Function to find working destination path
find_working_dest() {
    local dest_entry="$1"
    IFS=':' read -r dest_dir flags <<< "$dest_entry"
    
    # Check if :valid flag is present
    local has_valid_flag=false
    if [[ "$dest_entry" == *":valid"* ]]; then
        has_valid_flag=true
    fi
    
    # Check if original destination directory exists
    if [[ -d "$(dirname "$dest_dir")" ]]; then
        echo "$dest_entry"
        return 0
    fi
    
    # Try fallback path
    local fallback_dir
    fallback_dir=$(get_fallback_path "$dest_dir")
    
    if [[ -d "$(dirname "$fallback_dir")" ]]; then
        # Reconstruct the dest_entry with fallback path
        if [[ -n "$flags" ]]; then
            echo "$fallback_dir:$flags"
        else
            echo "$fallback_dir"
        fi
        return 0
    fi
    
    # If :valid flag is present, create the inner path only
    if [[ "$has_valid_flag" == true ]]; then
        # Check if the original parent exists to create the inner path there
        if [[ -d "$(dirname "$(dirname "$dest_dir")")" ]]; then
            info_msg="Creating inner path (valid flag): $dest_dir"
            echo "  ${bold}Info:${normal} $info_msg"
            info_messages+=("$info_msg")
            mkdir -p "$dest_dir"
            echo "$dest_entry"
            return 0
        fi
        
        # Check if the fallback parent exists to create the inner path there
        local fallback_parent
        fallback_parent=$(dirname "$fallback_dir")
        if [[ -d "$(dirname "$fallback_parent")" ]]; then
            info_msg="Creating inner path in fallback location (valid flag): $fallback_dir"
            echo "  ${bold}Info:${normal} $info_msg"
            info_messages+=("$info_msg")
            mkdir -p "$fallback_dir"
            if [[ -n "$flags" ]]; then
                echo "$fallback_dir:$flags"
            else
                echo "$fallback_dir"
            fi
            return 0
        fi
    fi
    
    # Neither path exists and no valid flag or no suitable parent
    return 1
}

# Function to check critical paths
check_critical_paths() {
    local critical_paths=(
        "$haha/product_a"
        "$haha/system_a"
    )
    
    for path in "${critical_paths[@]}"; do
        local fallback_path
        fallback_path=$(get_fallback_path "$path")
        
        if [[ ! -d "$path" && ! -d "$fallback_path" ]]; then
            error_msg="Critical destination path not found: $path (Fallback: $fallback_path)"
            echo "${bold}Error:${normal} $error_msg"
            errors+=("$error_msg")
            echo "Script cannot continue - destination not found."
            exit 1
        fi
    done
}

function update_privapp_xml() {
    local xml_file="$haha/product_a/etc/permissions/privapp-permissions-product.xml"
    
    # Try fallback path if primary doesn't exist
    if [[ ! -f "$xml_file" ]]; then
        local fallback_xml
        fallback_xml=$(get_fallback_path "$xml_file")
        if [[ -f "$fallback_xml" ]]; then
            xml_file="$fallback_xml"
        else
            warning_msg="XML file not found at $xml_file or fallback location"
            echo "  Warning: $warning_msg"
            warnings+=("$warning_msg")
            return 1
        fi
    fi
    
    # Check if permissions already exist
    if grep -q '<privapp-permissions package="com.android.contacts">' "$xml_file"; then
        echo "  Permissions already exist in XML"
        return
    fi

    echo "  Adding permissions to XML..."
    
    # Create temporary file with new permissions
    local tmpfile=$(mktemp)
    cat <<'EOF' > "$tmpfile"
   <privapp-permissions package="com.android.contacts">
      <permission name="android.permission.CALL_PRIVILEGED" />
      <permission name="android.permission.READ_PHONE_STATE" />
      <permission name="android.permission.MODIFY_PHONE_STATE" />
      <permission name="android.permission.ALLOW_ANY_CODEC_FOR_PLAYBACK" />
      <permission name="android.permission.REBOOT" />
      <permission name="android.permission.UPDATE_DEVICE_STATS" />
      <permission name="android.permission.WRITE_APN_SETTINGS" />
      <permission name="android.permission.WRITE_SECURE_SETTINGS" />
      <permission name="android.permission.BIND_DIRECTORY_SEARCH" />
      <permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" />
      <permission name="android.permission.INTERACT_ACROSS_USERS" />
   </privapp-permissions>
   <privapp-permissions package="com.android.incallui">
      <permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" />
      <permission name="android.permission.READ_PHONE_STATE" />
      <permission name="android.permission.MODIFY_PHONE_STATE" />
      <permission name="android.permission.CONTROL_INCALL_EXPERIENCE" />
      <permission name="android.permission.STOP_APP_SWITCHES" />
      <permission name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS" />
      <permission name="android.permission.STATUS_BAR" />
      <permission name="android.permission.CAPTURE_AUDIO_OUTPUT" />
      <permission name="android.permission.CALL_PRIVILEGED" />
      <permission name="android.permission.WRITE_MEDIA_STORAGE" />
      <permission name="android.permission.INTERACT_ACROSS_USERS" />
      <permission name="android.permission.MANAGE_USERS" />
      <permission name="android.permission.START_ACTIVITIES_FROM_BACKGROUND" />
   </privapp-permissions>
   <privapp-permissions package="com.android.mms">
      <permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" />
      <permission name="android.permission.READ_PHONE_STATE" />
      <permission name="android.permission.CALL_PRIVILEGED" />
      <permission name="android.permission.GET_ACCOUNTS_PRIVILEGED" />
      <permission name="android.permission.WRITE_SECURE_SETTINGS" />
      <permission name="android.permission.SEND_SMS_NO_CONFIRMATION" />
      <permission name="android.permission.SEND_RESPOND_VIA_MESSAGE" />
      <permission name="android.permission.UPDATE_APP_OPS_STATS" />
      <permission name="android.permission.MODIFY_PHONE_STATE" />
      <permission name="android.permission.WRITE_MEDIA_STORAGE" />
      <permission name="android.permission.MANAGE_USERS" />
      <permission name="android.permission.WRITE_APN_SETTINGS" />
      <permission name="android.permission.INTERACT_ACROSS_USERS" />
      <permission name="android.permission.SCHEDULE_EXACT_ALARM" />
   </privapp-permissions>
EOF

    # Insert after opening <permissions> tag
    sed -i -e '/<permissions>/r '"$tmpfile" "$xml_file"
    
    # Clean up temporary file
    rm "$tmpfile"
    
    echo "  XML permissions successfully updated"
}

# -- Main Script --
bold=$(tput bold)
normal=$(tput sgr0)
xml_updated=false

# Arrays to track errors and warnings
declare -a errors=()
declare -a warnings=()
declare -a info_messages=()

# Check critical paths before proceeding
echo "${bold}[0/4] Checking critical destination paths...${normal}"
check_critical_paths

# Parse targets and flags with fallback support
declare -A clear_dirs=()
declare -A content_sources=()
declare -A working_destinations=()

for source in "${!path_map[@]}"; do
    dest_entry="${path_map[$source]}"
    
    # Find working destination (original or fallback)
    if working_dest=$(find_working_dest "$dest_entry"); then
        working_destinations["$source"]="$working_dest"
        
        IFS=':' read -r dest_dir flags <<< "$working_dest"
        
        # Track directories needing clearance
        if [[ "$working_dest" == *":clear"* ]]; then
            clear_dirs["$dest_dir"]=1
        fi
        
        # Track sources needing content copy
        if [[ "$working_dest" == *":content"* ]]; then
            content_sources["$source"]=1
        fi
    else
        warning_msg="No valid destination found for $source"
        echo "  ${bold}Warning:${normal} $warning_msg"
        warnings+=("$warning_msg")
        echo "    Tried: $dest_entry"
        fallback_entry=$(get_fallback_path "$dest_entry")
        echo "    Fallback: $fallback_entry"
        echo "    Skipping this entry..."
    fi
done

# Clear targets
echo "${bold}[1/4] Preparing target directories...${normal}"
for dir in "${!clear_dirs[@]}"; do
    echo "  Clearing: $dir"
    mkdir -p "$dir"
    find "$dir" -mindepth 1 -delete 2>/dev/null || true
done

# Interactive installation
echo "${bold}[2/4] Component installation:${normal}"
for source in "${!working_destinations[@]}"; do
    dest_entry="${working_destinations[$source]}"
    IFS=':' read -r dest_dir flags <<< "$dest_entry"
    item_name=$(basename "$source")

    # Show prompt if configured
    if [[ -v "prompt_messages[$source]" ]]; then
        while true; do
            read -p "➜ ${bold}${prompt_messages[$source]}${normal} [y/N]: " answer
            case "${answer,,}" in
                y|yes)
                    # Update XML once per session
                    if ! $xml_updated; then
                        update_privapp_xml
                        xml_updated=true
                    fi
                    break
                    ;;
                n|no|"") 
                    echo "  Skipping $item_name"
                    continue 2
                    ;;
                *) 
                    echo "  Invalid choice, please enter y or n"
                    ;;
            esac
        done
    fi

    # Validate source exists
    if [[ ! -e "$source" ]]; then
        error_msg="Source '$source' missing"
        echo "  ${bold}Error:${normal} $error_msg"
        errors+=("$error_msg")
        continue
    fi

    # Show which destination is being used
    original_dest_entry="${path_map[$source]}"
    if [[ "$dest_entry" != "$original_dest_entry" ]]; then
        info_msg="Using fallback destination for $item_name"
        echo "  ${bold}Info:${normal} $info_msg"
        info_messages+=("$info_msg")
    fi

    # Copy operation
    mkdir -p "$dest_dir"
    if [[ -d "$source" && -v "content_sources[$source]" ]]; then
        echo "  Copying contents: $item_name → $dest_dir/"
        cp -r "$source/." "$dest_dir" 2>/dev/null || { 
            error_msg="Failed to copy contents from $source to $dest_dir"
            echo "  ${bold}Error:${normal} $error_msg"
            errors+=("$error_msg")
            continue
        }
        perm_path="$dest_dir"
    else
        dest_path="$dest_dir/$item_name"
        if [[ -d "$source" ]]; then
            echo "  Copying directory: $item_name → $dest_dir/"
            cp -r "$source" "$dest_dir" || { 
                error_msg="Directory copy failed: $source to $dest_dir"
                echo "  ${bold}Error:${normal} $error_msg"
                errors+=("$error_msg")
                continue
            }
        else
            echo "  Copying file: $item_name → $dest_dir/"
            cp "$source" "$dest_dir" || { 
                error_msg="File copy failed: $source to $dest_dir"
                echo "  ${bold}Error:${normal} $error_msg"
                errors+=("$error_msg")
                continue
            }
        fi
        perm_path="$dest_path"
    fi

    # Set permissions
    if [[ -e "$perm_path" ]]; then
        echo "  Setting permissions for: $perm_path"
        find "$perm_path" -type d -exec chmod 755 {} +
        find "$perm_path" -type f -exec chmod 644 {} +
    fi
done

echo "${bold}[3/4] Finalizing permissions...${normal}"
# Final permission sweep for copied items
find "$haha" -type d -exec chmod 755 {} +
find "$haha" -type f -exec chmod 644 {} +

echo "${bold}[4/4] Operation complete. XML permissions updated: $xml_updated${normal}"

# Summary of errors and warnings
echo
echo "${bold}=== OPERATION SUMMARY ===${normal}"

if [[ ${#errors[@]} -gt 0 ]]; then
    echo "${bold}Errors (${#errors[@]}):${normal}"
    for error in "${errors[@]}"; do
        echo "  ❌ $error"
    done
    echo
fi

if [[ ${#warnings[@]} -gt 0 ]]; then
    echo "${bold}Warnings (${#warnings[@]}):${normal}"
    for warning in "${warnings[@]}"; do
        echo "  ⚠️  $warning"
    done
    echo
fi

if [[ ${#info_messages[@]} -gt 0 ]]; then
    echo "${bold}Info Messages (${#info_messages[@]}):${normal}"
    for info in "${info_messages[@]}"; do
        echo "  ℹ️  $info"
    done
    echo
fi

if [[ ${#errors[@]} -eq 0 && ${#warnings[@]} -eq 0 ]]; then
    echo "${bold}✅ All operations completed successfully!${normal}"
else
    echo "${bold}📊 Operation completed with ${#errors[@]} error(s) and ${#warnings[@]} warning(s)${normal}"
fi

echo "${bold}XML permissions updated: $xml_updated${normal}"