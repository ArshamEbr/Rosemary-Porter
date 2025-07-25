#!/run/current-system/sw/bin/bash

hola="/home/arsham/rosemary/UKL/UnpackerSystem"
# Configuration
BUILD_PROP="${1:-$hola/system_a/system/build.prop}"
BACKUP_EXT=".bak"
TEMP_FILE="${BUILD_PROP}.tmp"
BARRIER="\n########## Pyro Build Modifications Start ##########\n"

PROPERTY_VALUES=(
    # Stock
    "ro.com.android.mobiledata=false"
    "ro.mtk_perf_simple_start_win=1"
    "ro.mtk_perf_fast_start_win=1"
    "ro.mtk_perf_response_time=1"
    "ro.vendor.mtk_omacp_support=1"
#    "dalvik.vm.ps-min-first-save-ms=0"
#    "pm.dexopt.install-bulk-secondary-downgraded=extract"
#    "pm.dexopt.post-boot=extract"

    "ro.surface_flinger.game_default_frame_rate_override=60"
)

COMMENT_OUT_PROPS=(
#    "ro.property_service.async_persist_writes"
#    "vendor.camera.aux.packagelist"
#    "ro.force.debuggable"
#    "ro.miui.shell_anim_enable_fcb"
#    "persist.hyper.barfollow_anim"
#    "dalvik.vm.usap_pool_enabled"
#    "dalvik.vm.usap_refill_threshold"
#    "dalvik.vm.usap_pool_size_max"
#    "dalvik.vm.usap_pool_size_min"
#    "dalvik.vm.usap_pool_refill_delay_ms"
#    "dalvik.vm.useartservice"
#    "dalvik.vm.enable_pr_dexopt"
#    "ro.apex.updatable"
#    "ro.hwui.max_texture_allocation_size"
#    "pm.dexopt.boot-after-ota.concurrency"
#    "pm.dexopt.boot-after-mainline-update"
#    "pm.dexopt.install-create-dm"
#    "pm.dexopt.baseline"
#    "pm.dexopt.secondary"
#    "ro.build.version.trunk"
#    "ro.radio.device_type"
#    "ro.vendor.audio.notification.single"
#    "ro.audio.ihaladaptervendorextension_enabled"
#    "ro.vendor.mtk_cta_set"
#    "vendor.af.threshold.src_and_effect_count"
#    "vendor.af.pausewait.enable"
#    "vendor.af.dynamic.sleeptime.enable"
#    "ro.audio.flinger_standbytime_ms"
#    "ro.vendor.system.mtk_mapi_support"
#    "debug.sf.enable_gl_backpressure"
#    "debug.sf.treat_170m_as_sRGB"
#    "ro.surface_flinger.game_default_frame_rate_override"
#    "ro.logd.auditd.main"
#    "ro.logd.auditd.events"
)

# Validate file
if [[ ! -f "$BUILD_PROP" ]]; then
    echo "❌ Error: File not found: $BUILD_PROP" >&2
    exit 1
fi

# Create backup
if ! cp -f "$BUILD_PROP" "${BUILD_PROP}${BACKUP_EXT}"; then
    echo "❌ Error: Backup failed" >&2
    exit 1
fi

# Capture original values with precise parsing
declare -A ORIGINAL_VALUES
while IFS= read -r line; do
    # Skip empty/commented lines (including leading whitespace)
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$line" ]] && continue

    # Clean line: remove inline comments and trim
    clean_line=$(echo "$line" | sed -E 's/[[:space:]]*#.*//; s/^[[:space:]]+//; s/[[:space:]]+$//')

    # Split into property=value with strict regex
    if [[ "$clean_line" =~ ^([^=[:space:]]+)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
        prop_name="${BASH_REMATCH[1]}"
        prop_value="${BASH_REMATCH[2]}"
        
        # Remove surrounding quotes if present
        prop_value=$(echo "$prop_value" | sed -E 's/^"(.*)"$/\1/; s/^'"'"'(.*)'"'"'$/\1/')
        
        ORIGINAL_VALUES["$prop_name"]="$prop_value"
    fi
done < "${BUILD_PROP}${BACKUP_EXT}"

# Create temp file
cp "$BUILD_PROP" "$TEMP_FILE"

# Get list of existing properties for modification detection
EXISTING_PROPS=$(grep -P '^[^#]\s*\w+\.\w+=' "$TEMP_FILE" | cut -d= -f1 | sort -u)

# Remove previous modifications if they exist
sed -i '/########## Pyro Build Modifications Start ##########/,/########## Pyro Build End ##########/d' "$TEMP_FILE"

# Initialize categorization arrays
MODIFIED_PROPERTIES=()
ADDED_PROPERTIES=()
UNMODIFIED_PROPERTIES=()

# Process property modifications
for prop_entry in "${PROPERTY_VALUES[@]}"; do
    prop_name="${prop_entry%%=*}"
    new_value="${prop_entry#*=}"
    
    if [[ -n "${ORIGINAL_VALUES[$prop_name]}" ]]; then
        original_value="${ORIGINAL_VALUES[$prop_name]}"
        
        if [[ "$new_value" != "$original_value" ]]; then
            MODIFIED_PROPERTIES+=("$prop_entry|$original_value")
        else
            UNMODIFIED_PROPERTIES+=("$prop_entry")
        fi
    else
        ADDED_PROPERTIES+=("$prop_entry")
    fi
    
    # Remove existing instances
    sed -i "/^#*[[:space:]]*${prop_name}=/d" "$TEMP_FILE"
done

# Process properties to comment out and move
for prop in "${COMMENT_OUT_PROPS[@]}"; do
    # Escape special characters for regex
    escaped_prop=$(sed 's/[.]/\\./g' <<< "$prop")
    
    # Find and process all matching lines
    while IFS= read -r line; do
        # Skip empty lines
        [[ -z "$line" ]] && continue
        
        # Preserve existing comments or add new
        if [[ "$line" =~ ^# ]]; then
            commented_line="$line"
        else
            commented_line="# $line"
        fi
        
        # Add to collected lines and remove from original
        COMMENTED_LINES+="${commented_line}\n"
        sed -i "/^[[:space:]]*${escaped_prop}=/d" "$TEMP_FILE"
        echo "✓ Commented/Moved: $prop"
    done < <(grep -P "^(#\s*)?${escaped_prop}=" "$TEMP_FILE")
done

# Add sections to temp file
echo -e "$BARRIER" >> "$TEMP_FILE"

# Removed Properties Section
echo -e "# Removed Properties:\n" >> "$TEMP_FILE"
echo -e "$COMMENTED_LINES" >> "$TEMP_FILE"

# Modified Properties Section
if [[ ${#MODIFIED_PROPERTIES[@]} -gt 0 ]]; then
    echo -e "\n# Modified Properties:\n" >> "$TEMP_FILE"
    for entry in "${MODIFIED_PROPERTIES[@]}"; do
        IFS='|' read -r prop_entry original_value <<< "$entry"
        prop_name="${prop_entry%%=*}"
        echo "$prop_entry    # Was: ${original_value}" >> "$TEMP_FILE"
        echo "✓ Modified: ${prop_entry} (was: '${original_value}')"
    done
fi

# Added Properties Section
if [[ ${#ADDED_PROPERTIES[@]} -gt 0 ]]; then
    echo -e "\n# Added Properties:\n" >> "$TEMP_FILE"
    for prop_entry in "${ADDED_PROPERTIES[@]}"; do
        echo "$prop_entry" >> "$TEMP_FILE"
        echo "✓ Added: $prop_entry"
    done
fi

# Unmodified Properties Section
if [[ ${#UNMODIFIED_PROPERTIES[@]} -gt 0 ]]; then
    echo -e "\n# Unmodified Properties (explicitly maintained):\n" >> "$TEMP_FILE"
    for prop_entry in "${UNMODIFIED_PROPERTIES[@]}"; do
        echo "$prop_entry" >> "$TEMP_FILE"
        echo "✓ Maintained: $prop_entry"
    done
fi

echo -e "########## Pyro Build End ########## \n" >> "$TEMP_FILE"

# Preserve original permissions
permissions=$(stat -c "%a" "$BUILD_PROP")
owner=$(stat -c "%U:%G" "$BUILD_PROP")

# Replace original file
mv "$TEMP_FILE" "$BUILD_PROP"
chmod "$permissions" "$BUILD_PROP"
chown "$owner" "$BUILD_PROP"

echo -e "\n✅ Pyro modifications grouped at end with visual barrier"
echo "📦 Backup saved: ${BUILD_PROP}${BACKUP_EXT}"