#!/run/current-system/sw/bin/bash

# Configuration
BUILD_PROP="${1:-/home/arsham/rosemary/UKL/UnpackerSystem/product_a/etc/build.prop}"
BACKUP_EXT=".bak"
TEMP_FILE="${BUILD_PROP}.tmp"
BARRIER="\n########## Pyro Build Modifications Start ##########\n"

# Property-value pairs to modify (property=new_value)
PROPERTY_VALUES=(
    "ro.miui.block_device_path=/dev/block/by-name"
    "ro.vendor.audio.spk.clean=true"
    "persist.audio.button_jack.profile=volume"
    "persist.audio.button_jack.switch=0"
    "ro.vendor.audio.game.effect=true"
    "vendor.audiohal.telephonytx.type=2"
    "ro.vendor.audio.soundfx.type=mi"
    "ro.vendor.audio.soundfx.usb=true"
    "ro.vendor.audio.voice.volume.boost=manual"
    "persist.bluetooth.disableabsvol=true"
    "ro.hardware.wlan.dbs=0"
    "persist.vendor.max.brightness=500"
    "ro.vendor.cabc.enable=true"
    "ro.vendor.colorpick_adjust=true"
    "ro.vendor.all_modes.colorpick_adjust=true"
    "ro.vendor.xiaomi.bl.poll=true"
    "ro.vendor.display.type=oled"
    "ro.vendor.audio.us.proximity=true"
    "sys.displayfeature_hidl=true"
    "vendor.displayfeature.entry.enable=true"
    "vendor.hbm.enable=true"
    "ro.hardware.fp.sideCap=true"
    "ro.vendor.client_handle_colorTransform=true"
    "ro.display.screen_type=1"
    "persist.sys.screen_anti_burn_enabled=true"

    "ro.miui.product.home=com.miui.home"
    "ro.build.characteristics=default"
    "persist.sys.disable_bganimate=false"

    "ro.product.product.name=rosemary"

    "persist.miui.extm.enable=0"
    "persist.sys.mms.bg_apps_limit=96"

    "persist.sys.use_boot_compact=true"
    "persist.sys.cts.testTrimMemActivityBg.wk.enable=true"

    "persist.sys.miui_modify_heap_config.enable=true"
    "ro.miui.support_prune=true"
    "ro.miui.support.enable_new_factory_reset=1"
    "persist.sys.cam_lowmem_restart=true"
    "persist.vendor.charge.oneTrack=true"
    "persist.sys.mms.compact_enable=true"
    "persist.sys.spc.enabled=true"
    "persist.sys.use_mi_new_strategy=true"
    "persist.sys.mmms.switch=true"

    "ro.miui.support_miui_ime_bottom=1"
    "ro.miui.support_super_clipboard=true"
    "persist.sys.support_super_clipboard=1"
    "ro.miui.backdrop_sampling_enabled=true"
########
    "ro.build.hardware.version=V1"
    "ro.miui.cust_hardware=V1"
    "ro.vendor.miui.cust_hardware=V1"
    "ro.se.type=eSE,HCE,UICC"
########

    "persist.miui.density_v2=440"
    "ro.sf.lcd_density=440"


    "vendor.perf.framepacing.enable=true"
    "persist.sys.background_blur_status_default=true" # T
    "enable_blurs_on_windows=1"
    "ro.sf.blurs_are_expensive=1"

    "ro.miui.notch=1"

    # Sea GL HOS2 Props
    "persist.miui.dexopt.first_use=false"
    "dalvik.vm.madvise.vdexfile.size=0"
    "ro.vendor.fps.switch.thermal=true"
    "persist.vendor.disable_idle_fps.threshold=60"
    "vendor.debug.sf.cpupolicy=0" # 0 
    "persist.sys.miuibooster.rtmode=true"
    "debug.sf.use_phase_offsets_as_duration=1"
    "debug.sf.high_fps.late.sf.duration=22000000"
    "ro.displayfeature.histogram.enable=true"
    "debug.sf.set_idle_timer_ms=10000" ####################
#    "dalvik.vm.heaptargetutilization=0.75" # 0.75
#    "dalvik.vm.heapminfree=2m" # 512k

    "bluetooth.profile.mcp.server.enabled=true"
    "bluetooth.profile.csip.set_coordinator.enabled=true"
    "bluetooth.profile.bap.unicast.client.enabled=true"
    "bluetooth.profile.vcp.controller.enabled=true"

    "persist.miui.extm.version=3.0"
    "ro.bluetooth.emb_wp_mode=false"
    "ro.whitepoint_calibration_enable=false"
    "persist.sys.support_view_smoothcorner=true"
    "persist.sys.migard.gamemode.enable=true"
    "persist.sys.spc.cpulimit.enabled=true"
    "ro.product.cpu.pagesize.max=4096"
    "ro.product.build.16k_page.enabled=true" # F

    # Corot
    "persist.sys.enable_sched_gpu_threads=true"
    "persist.sys.background_blur_supported=true"
    "persist.sys.miui_animator_sched.big_prime_cores=6-7"
    "persist.sys.millet.handshake=true"
    "persist.sys.miui_animator_sched.bigcores=6-7"
    "persist.sys.mmms.throttled.thread=7680"
    "persist.sys.unionpower.enable=true"
    "persist.sys.miui.sf_cores=4-7"
    "persist.sys.miui.render_boost=3"
    "dalvik.vm.boot-dex2oat-cpu-set=0,1,2,3,4,5,6,7"
    "dalvik.vm.image-dex2oat-cpu-set=0,1,2,3,4,5,6,7"
    "dalvik.vm.background-dex2oat-cpu-set=0,1,2,3,4,5"
    "dalvik.vm.dex2oat-threads=6"
    "ro.vendor.idle_fps=45"

    # Dolby Pro Max
    "persist.vendor.audio.misound.disable=true"
    "ro.vendor.audio.dolby.dax.support=true"
    "ro.vendor.audio.hifi=true"
    "ro.vendor.audio.sfx.earadj=true"
    "ro.vendor.audio.scenario.support=true"
    "ro.vendor.audio.sfx.scenario=true"
    "ro.vendor.audio.surround.support=true"
    "ro.vendor.audio.vocal.support=true"
    "ro.vendor.audio.voice.change.support=true"
    "ro.vendor.audio.voice.change.youme.support=true"
    "ro.vendor.audio.game.mode=true"
    "ro.vendor.audio.sos=true"
    "ro.vendor.audio.soundtrigger.mtk.pangaea=1"
    "ro.vendor.audio.soundtrigger.xiaomievent=1"
    "ro.vendor.audio.soundtrigger.wakeupword=5"
    "ro.vendor.audio.soundtrigger.mtk.split_training=1"
    "ro.vendor.dolby.dax.version=DAX3_3.6.0.12_r1"
    "ro.vendor.audio.5k=true"
    "ro.vendor.audio.feature.spatial=0"
    "ro.audio.monitorRotation=true"
    "ro.vendor.audio.dolby.vision.support=true"
    "ro.vendor.display.dolbyvision.support=true"
    "ro.vendor.audio.bass.enhancer.enable=true"
    "debug.config.media.video.dolby_vision_suports=true"
    
    # PQ Pro Max
    "vendor.debug.pq.dshp.en=0"
    "vendor.debug.pq.shp.en=0"
    "persist.vendor.sys.pq.iso.shp.en=0"
    "persist.vendor.sys.pq.ultrares.en=0"
    "persist.vendor.sys.pq.shp.idx=0"
    "persist.vendor.sys.pq.shp.strength=0"
    "persist.vendor.sys.pq.shp.step=0"
    "persist.vendor.sys.pq.dispshp.strength=0"
    "persist.vendor.sys.pq.ultrares.strength=0"

    "ro.product.mod_device=rosemary" # *********************************

    "persist.sys.app_dexfile_preload.enable=false"
    "persist.sys.usap_pool_enabled=false"
    "persist.sys.dynamic_usap_enabled=false"
    "persist.sys.spc.proc_restart_enable=false"
    "persist.sys.preload.enable=false"
    "persist.sys.precache.enable=false"
    "persist.sys.prestart.proc=false"
    "persist.sys.prestart.feedback.enable=false"
    "persist.sys.performance.appLaunchPreload.enable=false"
    "persist.sys.smartcache.enable=false"
    "persist.sys.art_startup_class_preload.enable=false"
    
)

# Properties to comment out (will preserve original value as comment)
COMMENT_OUT_PROPS=(
    # Corot Global HOS2 Props
    "ro.surface_flinger.ignore_hdr_camera_layers"         # T
    "persist.sys.app_resurrection.enable"                 # T
    "persist.sys.powmillet.enable"                        # T
    "persist.sys.hdr_dimmer_supported"                    # T
    "persist.sys.hdr_dimmer.hight_perf_mode"              # T
    "ro.vendor.miui.support_esim"                         # T
    "ro.miui.carrier.cota"                                # T
    "ro.miui.cust_erofs"
    "persist.sys.dexpreload.big_prime_cores"
    "ro.vendor.radio.5g"

    "ro.netflix.channel"
    "ro.netflix.signup"
    "ro.wps.prop.channel.path"
    "ro.trackingId.com.lzd.appid"
    "ro.csc.spotify.music.referrerid"
    "ro.csc.spotify.music.partnerid"
    "ro.booking.channel.path"
    "ro.zalo.tracking"
    "ro.com.agoda.consumer.preload"
    "ro.miui.pai.preinstall.path"
    "ro.appsflyer.preinstall.path"

    "persist.sys.dexpreload.cpu_cores"   # 0-7
    "persist.sys.dexpreload.other_cores" # 0-6

    "ro.vendor.vodata_support"

    "persist.sys.precache.number"
    "persist.sys.precache.appstrs6"
    "persist.sys.precache.appstrs5"
    "persist.sys.precache.appstrs4"
    "persist.sys.precache.appstrs3"
    "persist.sys.precache.appstrs2"
    "persist.sys.precache.appstrs1"

    "ro.config.low_ram.threshold_gb"
)

# Add dynamic fingerprint modification (NEW SECTION) - UNTOUCHED AS REQUESTED
FINGERPRINT_PATTERN="^ro\.product\.build\.fingerprint="
REPLACEMENT_DEVICE="rosemary"

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

# Process fingerprints before other modifications (UNTOUCHED AS REQUESTED)
while IFS= read -r line; do
    if [[ "$line" =~ $FINGERPRINT_PATTERN ]]; then
        # Split fingerprint into components
        modified_line=$(echo "$line" | sed -E "s|([^/]*/)[^/]*(/.*)|\1${REPLACEMENT_DEVICE}\2|")
        
        # Add to modification list
        PROPERTY_VALUES+=("$modified_line")
        
        # Remove original from file
        sed -i "/^#*[[:space:]]*$(echo "$line" | sed 's|/|\\/|g')/d" "$TEMP_FILE"
        
        echo "✓ Fingerprint modified: $line → $modified_line"
    fi
done < <(grep -P "$FINGERPRINT_PATTERN" "$TEMP_FILE")

# Remove previous modifications if they exist
sed -i '/########## Pyro Build Modifications Start ##########/,/########## Pyro Build End ##########/d' "$TEMP_FILE"

# Initialize categorization arrays
MODIFIED_PROPERTIES=()
ADDED_PROPERTIES=()
UNMODIFIED_PROPERTIES=()

# Process property modifications
for prop_entry in "${PROPERTY_VALUES[@]}"; do
    IFS='=' read -r prop_name new_value <<< "$prop_entry"
    
    # Check if property exists in original file
    if [[ -n "${ORIGINAL_VALUES[$prop_name]}" ]]; then
        original_value="${ORIGINAL_VALUES[$prop_name]}"
        
        if [[ "$new_value" != "$original_value" ]]; then
            MODIFIED_PROPERTIES+=("$prop_name=$new_value|$original_value")
            # Remove existing instances from the file
            sed -i "/^[[:space:]]*#*[[:space:]]*${prop_name}=/d" "$TEMP_FILE"
        else
            UNMODIFIED_PROPERTIES+=("$prop_name=$new_value")
            # Keep the original line in the file
            sed -i "/^[[:space:]]*#*[[:space:]]*${prop_name}=/d" "$TEMP_FILE"
        fi
    else
        ADDED_PROPERTIES+=("$prop_name=$new_value")
    fi
done

# Process properties to comment out and move
COMMENTED_LINES=""
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
            # Extract the actual property name from the line
            if [[ "$line" =~ ^[[:space:]]*([^=[:space:]]+) ]]; then
                prop_name="${BASH_REMATCH[1]}"
                # Store original value if not already stored
                if [[ -z "${ORIGINAL_VALUES[$prop_name]}" ]]; then
                    clean_line=$(echo "$line" | sed -E 's/[[:space:]]*#.*//')
                    if [[ "$clean_line" =~ ^[^=]+=(.*)$ ]]; then
                        ORIGINAL_VALUES["$prop_name"]="${BASH_REMATCH[1]}"
                    fi
                fi
            fi
            commented_line="# $line"
        fi
        
        # Add to collected lines and remove from original
        COMMENTED_LINES+="${commented_line}\n"
        sed -i "/^[[:space:]]*${escaped_prop}=/d" "$TEMP_FILE"
        echo "✓ Commented/Moved: $prop"
    done < <(grep -P "^(#\s*)?${escaped_prop}=" "$TEMP_FILE" || true)
done

# Add sections to temp file
echo -e "$BARRIER" >> "$TEMP_FILE"

# Removed Properties Section
if [[ -n "$COMMENTED_LINES" ]]; then
    echo -e "# Removed Properties:\n" >> "$TEMP_FILE"
    echo -e "$COMMENTED_LINES" >> "$TEMP_FILE"
fi

# Modified Properties Section
if [[ ${#MODIFIED_PROPERTIES[@]} -gt 0 ]]; then
    echo -e "\n# Modified Properties:\n" >> "$TEMP_FILE"
    for entry in "${MODIFIED_PROPERTIES[@]}"; do
        IFS='|' read -r prop_entry original_value <<< "$entry"
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