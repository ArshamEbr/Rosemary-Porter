#!/run/current-system/sw/bin/bash

# PyroOS Combined Script
# Combines all Pyro modification scripts with interactive menu system
# Author: Arsham
# License: MIT

# Configuration
BASE_DIR="/home/arsham/rosemary/UKL/UnpackerSystem"
SUPER_SOURCE_DIR="/home/arsham/rosemary/UKL/UnpackerSystem"
SUPER_TARGET_DIR="/home/arsham/rosemary/UKL/UnpackerSuper"
OUTPUT_DIR="/home/arsham/rosemary/output"
LOG_FILE="pyro_combined_$(date +%Y%m%d_%H%M%S).log"

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NORMAL='\033[0m'

# Script definitions
declare -A SCRIPTS=(
    [1]="Pyro_debloater|Remove unwanted apps and bloatware"
    [2]="Pyro_product_prop_builder|Modify product build properties"
    [3]="Pyro_copier|Copy custom components and overlays"
    [4]="Pyro_miext_mover|Move mi_ext contents to main partitions"
    [5]="Pyro_miext_prop_builder|Modify mi_ext build properties"
    [6]="Pyro_system_prop_builder|Modify system build properties"
    [7]="Pyro_system_ext_prop_builder|Modify system_ext build properties"
    [8]="Super_packer_4000|Build sparse super image from partitions"
)

# Function definitions
print_header() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                               ║"
    echo "║           ██████╗ ██╗   ██╗██████╗  ██████╗       ██████╗ ███████╗            ║"
    echo "║           ██╔══██╗╚██╗ ██╔╝██╔══██╗██╔═══██╗     ██╔═══██╗██╔════╝            ║"
    echo "║           ██████╔╝ ╚████╔╝ ██████╔╝██║   ██║     ██║   ██║███████╗            ║"
    echo "║           ██╔═══╝   ╚██╔╝  ██╔══██╗██║   ██║     ██║   ██║╚════██║            ║"
    echo "║           ██║        ██║   ██║  ██║╚██████╔╝     ╚██████╔╝███████║            ║"
    echo "║           ╚═╝        ╚═╝   ╚═╝  ╚═╝ ╚═════╝       ╚═════╝ ╚══════╝            ║"
    echo "║                                                                               ║"
    echo "║                         🔥 B U I L D   S U I T E 🔥                           ║"
    echo "║                                 Script v1.1                                   ║"
    echo "║                                                                               ║"
    echo "╠═══════════════════════════════════════════════════════════════════════════════╣"
    echo "║                                                                               ║"
    echo "║                                💎 CREDITS 💎                                  ║"
    echo "║                                                                               ║"
    echo "║    🚀 @ArshamEbr     - Creator of the automation script                       ║"
    echo "║    📚 @NEESCHAL_3    - A friend who guided me in learning about ROMs          ║"
    echo "║    🌟 @PapaAlpha32   - the person who started my first ROM porting journey    ║"
    echo "║                                                                               ║"
    echo "║                      Special thanks to the community! 🙏                      ║"
    echo "║                                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NORMAL}"
    
    # Show splash screen for 2 seconds
    sleep 2
    
    echo -e "${CYAN}Base Directory: ${BOLD}$BASE_DIR${NORMAL}"
    echo -e "${CYAN}Super Target: ${BOLD}$SUPER_TARGET_DIR${NORMAL}"
    echo -e "${CYAN}Output Directory: ${BOLD}$OUTPUT_DIR${NORMAL}"
    echo -e "${CYAN}Log File: ${BOLD}$LOG_FILE${NORMAL}\n"
}

print_menu() {
    echo -e "${BOLD}${BLUE}Available Scripts:${NORMAL}"
    echo -e "${BLUE}────────────────────────────────────────────────────────────${NORMAL}"
    
    for i in {1..8}; do
        IFS='|' read -r script_name description <<< "${SCRIPTS[$i]}"
        echo -e "  ${YELLOW}[$i]${NORMAL} ${BOLD}$script_name${NORMAL}"
        echo -e "      ${description}"
    done
    
    echo -e "\n${BOLD}${GREEN}Options:${NORMAL}"
    echo -e "${GREEN}────────────────────────────────────────────────────────────${NORMAL}"
    echo -e "  ${YELLOW}[A]${NORMAL} ${BOLD}Run ALL scripts in sequence${NORMAL}"
    echo -e "  ${YELLOW}[S]${NORMAL} ${BOLD}Select SPECIFIC scripts to run${NORMAL}"
    echo -e "  ${YELLOW}[Q]${NORMAL} ${BOLD}Quit${NORMAL}"
}

validate_environment() {
    echo -e "${BOLD}${CYAN}[INIT] Validating environment...${NORMAL}"
    
    if [[ ! -d "$BASE_DIR" ]]; then
        echo -e "${RED}❌ Error: Base directory not found: $BASE_DIR${NORMAL}" >&2
        exit 1
    fi
    
    # Check for critical directories
    local critical_dirs=("$BASE_DIR/product_a" "$BASE_DIR/system_a")
    for dir in "${critical_dirs[@]}"; do
        local fallback_dir="${dir/_a/}"
        if [[ ! -d "$dir" && ! -d "$fallback_dir" ]]; then
            echo -e "${YELLOW}⚠️ Warning: Neither $dir nor $fallback_dir found${NORMAL}"
        fi
    done
    
    # Check super packer directories
    if [[ ! -d "$SUPER_TARGET_DIR" ]]; then
        echo -e "${YELLOW}⚠️ Warning: Super target directory not found: $SUPER_TARGET_DIR${NORMAL}"
    fi
    
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        echo -e "${BLUE}ℹ️ Creating output directory: $OUTPUT_DIR${NORMAL}"
        mkdir -p "$OUTPUT_DIR" || {
            echo -e "${RED}❌ Error: Failed to create output directory: $OUTPUT_DIR${NORMAL}" >&2
            exit 1
        }
    fi
    
    echo -e "${GREEN}✅ Environment validation complete${NORMAL}\n"
}

log_message() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

run_debloater() {
    echo -e "${BOLD}${CYAN}[1/7] Running Pyro Debloater...${NORMAL}"
    log_message "INFO" "Starting Pyro_debloater"
    
    # Debloater configuration
    local TARGET_DIRS=(
        "$BASE_DIR/system_ext_a/app"
        "$BASE_DIR/system_ext_a/priv-app"
        "$BASE_DIR/system_a/system/app"
        "$BASE_DIR/system_a/system/priv-app"
        "$BASE_DIR/system_a/system/system_ext/app"
        "$BASE_DIR/system_a/system/system_ext/priv-app"
        "$BASE_DIR/product_a/app"
        "$BASE_DIR/product_a/priv-app"
        "$BASE_DIR/product_a/data-app"
        "$BASE_DIR/product_a/pangu/system/app"
        "$BASE_DIR/product_a/pangu/system/priv-app"
        "$BASE_DIR/mi_ext_a/product/app"
        "$BASE_DIR/mi_ext_a/product/priv-app"
        "$BASE_DIR/mi_ext_a/product/data-app"
        "$BASE_DIR/mi_ext_a/system/app"
        "$BASE_DIR/mi_ext_a/system/priv-app"
        "$BASE_DIR/mi_ext_a/system/data-app"
        "$BASE_DIR/vendor_a/app"
        "$BASE_DIR/vendor_a/priv-app"
    )

    local FOLDERS_TO_REMOVE=(
        "Chrome" "com.google.mainline.go.telemetry" "DuoGo" "GoogleOne"
        "MiGalleryLockScreenGlobalGO" "AssistantGo" "GoogleDialerGo" "DuoGo"
        "MiPicks" "TraceurGo" "BugreportGo" "AnalyticsCoreGo" "GoogleSearchGo"
        "MessagesGo" "AutoTest" "GFTest" "MiBrowserLite" "GlobalCleanerGo"
        "MIUIVideo" "MIUIVipAccount" "ThirdAppAssistant" "MiRadio"
        "MIGalleryLockscreen-MIUI15" "MiBugReport" "LogManager"
        "MiuiContentCatcherMIUI15" "MIUITouchAssistant" "MIUIGuardProvider"
        "SystemHelper" "XMDualCameraCaliO16" "MIUIPersonalAssistantPhoneO16"
        "MiLauncherGlobal" "MIUICloudBackup" "MiGameCenterSDKService"
        "MIRadioGlobal" "MiuiBiometric33148" "MiuiBugReportGlobal" "GoogleNews"
        "MiGalleryLockScreenGlobal" "Podcasts" "Turbo" "cit" "SettingsIntelligence"
        "PrivateComputeServices" "Longcheer_GFTest" "Longcheer_SensorTestTool"
        "MIGalleryLockscreen-T" "BHPService" "MiuiBiometric33127"
        "mi_connect_service_t" "SimActivateService" "SogouInput" "MiGameService_MTK"
        "XiaoaiRecommendation" "OtaProvision" "com.iflytek.inputmethod.miui"
        "MIUIPersonalAssistant" "VoiceTrigger" "MIUIMirrorSmarthubNoneFeature"
        "CatcherPatch" "KSICibaEngine" "MiuiContentCatcher" "MIUINewHome_Removable"
        "MIUIgreenguard" "com.xiaomi.macro" "HotwordEnrollmentOKGoogleCORTEXM4"
        "HotwordEnrollmentXGoogleCORTEXM4" "MIUIGlobalMinusScreen"
        "MiGalleryLockScreenGlobalT" "POCOCOMMUNITY_OVERSEA" "POCOSTORE_OVERSEA"
        "Traceur" "MIUIMiRcsGlobal" "SearchSelector" "AiCore_V" "VelvetCtS"
        "MIUIAICR" "facebook-appmanager" "facebook-installer" "facebook-services"
        "MiuiDaemon" "MDMConfig" "MDMLSamples" "MDMLSample" "MipayService"
        "talkback" "mi_connect_service" "SoterService" "PaymentService" "MSA"
        "MIUISuperMarket" "MIUICloudService" "MIUIMiCloudSync" "MIUIAiasstService"
        "MIUIAccessibility" "MINextpay" "IFAAService" "HybridPlatform"
        "GoogleLocationHistory" "CarWith" "AnalyticsCore" "AiasstVision"
        "AiAsstVision" "MIUIReporter" "Updater" "XiaomiRecommendation"
        "XiaomiSimActivateService" "VoiceAssistAndroidT" "SogouIME"
        "MiBugReportOS2" "UPTsmService" "Chrome64" "com.google.mainline.adservices"
        "com.google.mainline.telemetry" "CatchLog" "com.xiaomi.ugd" "Drive"
        "Gmail2" "Biometric" "MiuiBiometric" "GoogleLocationHistory" "Maps"
        "Meet" "MiBugReportOS2Global" "mi_connect_service" "MiTrustService"
        "MiuiCit" "MIUICloudServiceGlobal" "MIUIGuardProviderGlobal"
        "MIUIHealthGlobal" "MIUIMiCloudSync" "MIUISystemAppUpdater"
        "MIUITouchAssistantGlobal" "MSA-Global" "Photos" "PlayAutoInstallStubApp"
        "SimActivateServiceGlobal" "SpeechServicesByGoogle" "SwitchAccess"
        "talkback" "Updater" "Videos" "YTMusic" "YouTube" "MiGameSDKService"
        "MIUIYellowPage" "MIUIQuickSearchBox" "MIUIPersonalAssistantPhoneOS2NoBeta"
        "MIUIBrowser" "AndroidAutoStub" "Backup" "DeviceIntegrationService"
        "DownloadProviderUi" "FamilyLinkParentalControls" "GoogleRestore"
        "HotwordEnrollmentOKGoogleRISCV" "HotwordEnrollmentXGoogleRISCV"
        "LinkToWindows" "MIServiceGlobal" "MIUIAccessibility"
        "MIUICleanMasterGlobal-cleaner" "MIUICloudBackupGlobal" "MIUIMusicGlobal"
        "MIUIVideoPlayer" "PersonalSafety" "Wellbeing" "Velvet" "wps-lite"
        "iFlytekIME" "SmartHome" "OS2VipAccount" "MiShop" "MIpay" "MIUIYoupin"
        "MIUIXiaoAiSpeechEngine" "MIUIVirtualSim" "MIUIMusicT" "MIUIMiDrive"
        "MIUIHuanji" "MIUIGameCenter" "MIUIEmail" "MIUIDuokanReader"
        "MIUICleanMaster" "Health" "BaiduIME" "DownloadProviderUI" "MIService"
        "MiGalleryLockScreenGlobalOs020" "MIUINotes" "MiuiScanner" "IFAAService"
        "CalendarGoogle" "GameCenterGlobal" "GoogleContacts" "GoogleOne_arm64"
        "MIUIMiPicks" "PaymentService_Global" "SoterService" "GlobalWPSLITE"
        "GoogleNews_xxhdpi" "MICOMMUNITY_OVERSEA" "MIDrop" "MISTORE_OVERSEA"
        "MIUIHuanjiGlobal" "SmartHome" "GoogleAssistant" "AppBox"
        "GoogleDialer_arm64" "AppCenter" "HealthConnectStub" "AppCloud"
        "Messages_arm64_xxhdpi" "bygIgnite" "MIBrowserGlobal_builtin_before_2021"
        "com.altice.android.myapps" "com.dti.telefonica" "MIUIEsimLPA"
        "com.sfr.android.sfrjeux" "MIUIGlobalMinusScreenWidget"
        "MIUIYellowPageGlobal" "CotaService" "OrangeManualSelector"
        "CrossDeviceServices" "AppEnabler" "AppSelector"
    )

    local removed_count=0
    for TARGET_DIR in "${TARGET_DIRS[@]}"; do
        # Try fallback paths if _a versions don't exist
        if [[ ! -d "$TARGET_DIR" ]]; then
            local fallback_dir="${TARGET_DIR/_a/}"
            if [[ -d "$fallback_dir" ]]; then
                TARGET_DIR="$fallback_dir"
            else
                continue
            fi
        fi
        
        for folder in "${FOLDERS_TO_REMOVE[@]}"; do
            local FULL_PATH="$TARGET_DIR/$folder"
            if [[ -d "$FULL_PATH" ]]; then
                echo -e "  ${RED}🗑️  Removing: $FULL_PATH${NORMAL}"
                rm -rf "$FULL_PATH"
                ((removed_count++))
                log_message "INFO" "Removed: $FULL_PATH"
            fi
        done
    done

    echo -e "${GREEN}✅ Debloater complete! Removed $removed_count items.${NORMAL}\n"
    log_message "INFO" "Pyro_debloater completed successfully. Removed $removed_count items."
}

run_prop_builder() {
    local prop_type="$1"
    local build_prop="$2"
    local step_num="$3"
    local total_steps="$4"
    
    echo -e "${BOLD}${CYAN}[$step_num/$total_steps] Running Pyro ${prop_type} Property Builder...${NORMAL}"
    log_message "INFO" "Starting Pyro_${prop_type}_prop_builder"
    
    # Try fallback path if primary doesn't exist
    if [[ ! -f "$build_prop" ]]; then
        local fallback_prop="${build_prop/_a/}"
        if [[ -f "$fallback_prop" ]]; then
            build_prop="$fallback_prop"
            echo -e "  ${YELLOW}ℹ️  Using fallback: $build_prop${NORMAL}"
        else
            echo -e "  ${RED}❌ Error: Build prop not found: $build_prop${NORMAL}"
            log_message "ERROR" "Build prop not found: $build_prop"
            return 1
        fi
    fi
    
    # Property configurations for each type
    local -A PROPERTY_VALUES
    local -A COMMENT_OUT_PROPS
    
    case "$prop_type" in
        "product")
            PROPERTY_VALUES=(
                ["ro.miui.block_device_path"]="/dev/block/by-name"
                ["ro.vendor.audio.spk.clean"]="true"
                ["persist.audio.button_jack.profile"]="volume"
                ["persist.audio.button_jack.switch"]="0"
                ["ro.vendor.audio.game.effect"]="true"
                ["vendor.audiohal.telephonytx.type"]="2"
                ["ro.vendor.audio.soundfx.type"]="mi"
                ["ro.vendor.audio.soundfx.usb"]="true"
                ["ro.vendor.audio.voice.volume.boost"]="manual"
                ["persist.bluetooth.disableabsvol"]="true"
                ["ro.hardware.wlan.dbs"]="0"
                ["persist.vendor.max.brightness"]="500"
                ["ro.vendor.cabc.enable"]="true"
                ["ro.vendor.colorpick_adjust"]="true"
                ["ro.vendor.all_modes.colorpick_adjust"]="true"
                ["ro.vendor.xiaomi.bl.poll"]="true"
                ["ro.vendor.display.type"]="oled"
                ["ro.vendor.audio.us.proximity"]="true"
                ["sys.displayfeature_hidl"]="true"
                ["vendor.displayfeature.entry.enable"]="true"
                ["vendor.hbm.enable"]="true"
                ["ro.hardware.fp.sideCap"]="true"
                ["ro.vendor.client_handle_colorTransform"]="true"
                ["ro.display.screen_type"]="1"
                ["persist.sys.screen_anti_burn_enabled"]="true"
                ["ro.miui.product.home"]="com.miui.home"
                ["ro.build.characteristics"]="default"
                ["persist.sys.disable_bganimate"]="false"
                ["ro.product.product.name"]="rosemary"
                ["persist.miui.extm.enable"]="0"
                ["persist.sys.mms.bg_apps_limit"]="96"
                ["persist.sys.use_boot_compact"]="true"
                ["persist.sys.cts.testTrimMemActivityBg.wk.enable"]="true"
                ["persist.sys.miui_modify_heap_config.enable"]="true"
                ["ro.miui.support_prune"]="true"
                ["ro.miui.support.enable_new_factory_reset"]="1"
                ["persist.sys.cam_lowmem_restart"]="true"
                ["persist.vendor.charge.oneTrack"]="true"
                ["persist.sys.mms.compact_enable"]="true"
                ["persist.sys.spc.enabled"]="true"
                ["persist.sys.use_mi_new_strategy"]="true"
                ["persist.sys.mmms.switch"]="true"
                ["ro.miui.support_miui_ime_bottom"]="1"
                ["ro.miui.support_super_clipboard"]="true"
                ["persist.sys.support_super_clipboard"]="1"
                ["ro.miui.backdrop_sampling_enabled"]="true"
                ["ro.build.hardware.version"]="V1"
                ["ro.miui.cust_hardware"]="V1"
                ["ro.vendor.miui.cust_hardware"]="V1"
                ["ro.se.type"]="eSE,HCE,UICC"
                ["persist.miui.density_v2"]="440"
                ["ro.sf.lcd_density"]="440"
                ["vendor.perf.framepacing.enable"]="true"
                ["persist.sys.background_blur_status_default"]="true"
                ["enable_blurs_on_windows"]="1"
                ["ro.sf.blurs_are_expensive"]="1"
                ["ro.miui.notch"]="1"
                ["persist.miui.dexopt.first_use"]="false"
                ["dalvik.vm.madvise.vdexfile.size"]="0"
                ["ro.vendor.fps.switch.thermal"]="true"
                ["persist.vendor.disable_idle_fps.threshold"]="60"
                ["vendor.debug.sf.cpupolicy"]="0"
                ["persist.sys.miuibooster.rtmode"]="true"
                ["debug.sf.use_phase_offsets_as_duration"]="1"
                ["debug.sf.high_fps.late.sf.duration"]="22000000"
                ["ro.displayfeature.histogram.enable"]="true"
                ["debug.sf.set_idle_timer_ms"]="10000"
                ["bluetooth.profile.mcp.server.enabled"]="true"
                ["bluetooth.profile.csip.set_coordinator.enabled"]="true"
                ["bluetooth.profile.bap.unicast.client.enabled"]="true"
                ["bluetooth.profile.vcp.controller.enabled"]="true"
                ["persist.miui.extm.version"]="3.0"
                ["ro.bluetooth.emb_wp_mode"]="false"
                ["ro.whitepoint_calibration_enable"]="false"
                ["persist.sys.support_view_smoothcorner"]="true"
                ["persist.sys.migard.gamemode.enable"]="true"
                ["persist.sys.spc.cpulimit.enabled"]="true"
                ["ro.product.cpu.pagesize.max"]="4096"
                ["ro.product.build.16k_page.enabled"]="true"
                ["persist.sys.enable_sched_gpu_threads"]="true"
                ["persist.sys.background_blur_supported"]="true"
                ["persist.sys.miui_animator_sched.big_prime_cores"]="6-7"
                ["persist.sys.millet.handshake"]="true"
                ["persist.sys.miui_animator_sched.bigcores"]="6-7"
                ["persist.sys.mmms.throttled.thread"]="7680"
                ["persist.sys.unionpower.enable"]="true"
                ["persist.sys.miui.sf_cores"]="4-7"
                ["persist.sys.miui.render_boost"]="3"
                ["dalvik.vm.boot-dex2oat-cpu-set"]="0,1,2,3,4,5,6,7"
                ["dalvik.vm.image-dex2oat-cpu-set"]="0,1,2,3,4,5,6,7"
                ["dalvik.vm.background-dex2oat-cpu-set"]="0,1,2,3,4,5"
                ["dalvik.vm.dex2oat-threads"]="6"
                ["ro.vendor.idle_fps"]="45"
                ["persist.vendor.audio.misound.disable"]="true"
                ["ro.vendor.audio.dolby.dax.support"]="true"
                ["ro.vendor.audio.hifi"]="true"
                ["ro.vendor.audio.sfx.earadj"]="true"
                ["ro.vendor.audio.scenario.support"]="true"
                ["ro.vendor.audio.sfx.scenario"]="true"
                ["ro.vendor.audio.surround.support"]="true"
                ["ro.vendor.audio.vocal.support"]="true"
                ["ro.vendor.audio.voice.change.support"]="true"
                ["ro.vendor.audio.voice.change.youme.support"]="true"
                ["ro.vendor.audio.game.mode"]="true"
                ["ro.vendor.audio.sos"]="true"
                ["ro.vendor.audio.soundtrigger.mtk.pangaea"]="1"
                ["ro.vendor.audio.soundtrigger.xiaomievent"]="1"
                ["ro.vendor.audio.soundtrigger.wakeupword"]="5"
                ["ro.vendor.audio.soundtrigger.mtk.split_training"]="1"
                ["ro.vendor.dolby.dax.version"]="DAX3_3.6.0.12_r1"
                ["ro.vendor.audio.5k"]="true"
                ["ro.vendor.audio.feature.spatial"]="0"
                ["ro.audio.monitorRotation"]="true"
                ["ro.vendor.audio.dolby.vision.support"]="true"
                ["ro.vendor.display.dolbyvision.support"]="true"
                ["ro.vendor.audio.bass.enhancer.enable"]="true"
                ["debug.config.media.video.dolby_vision_suports"]="true"
                ["vendor.debug.pq.dshp.en"]="0"
                ["vendor.debug.pq.shp.en"]="0"
                ["persist.vendor.sys.pq.iso.shp.en"]="0"
                ["persist.vendor.sys.pq.ultrares.en"]="0"
                ["persist.vendor.sys.pq.shp.idx"]="0"
                ["persist.vendor.sys.pq.shp.strength"]="0"
                ["persist.vendor.sys.pq.shp.step"]="0"
                ["persist.vendor.sys.pq.dispshp.strength"]="0"
                ["persist.vendor.sys.pq.ultrares.strength"]="0"
                ["ro.product.mod_device"]="rosemary"
                ["persist.sys.app_dexfile_preload.enable"]="false"
                ["persist.sys.usap_pool_enabled"]="false"
                ["persist.sys.dynamic_usap_enabled"]="false"
                ["persist.sys.spc.proc_restart_enable"]="false"
                ["persist.sys.preload.enable"]="false"
                ["persist.sys.precache.enable"]="false"
                ["persist.sys.prestart.proc"]="false"
                ["persist.sys.prestart.feedback.enable"]="false"
                ["persist.sys.performance.appLaunchPreload.enable"]="false"
                ["persist.sys.smartcache.enable"]="false"
                ["persist.sys.art_startup_class_preload.enable"]="false"
            )
            ;;
        "system")
            PROPERTY_VALUES=(
                ["ro.com.android.mobiledata"]="false"
                ["ro.mtk_perf_simple_start_win"]="1"
                ["ro.mtk_perf_fast_start_win"]="1"
                ["ro.mtk_perf_response_time"]="1"
                ["ro.vendor.mtk_omacp_support"]="1"
                ["ro.surface_flinger.game_default_frame_rate_override"]="60"
            )
            ;;
        "system_ext")
            PROPERTY_VALUES=(
                ["ro.surface_flinger.supports_background_blur"]="1"
                ["persist.sys.miui_scout_enable"]="true"
            )
            ;;
        "miext")
            PROPERTY_VALUES=(
                ["ro.product.mod_device"]="rosemary"
            )
            ;;
    esac
    
    # Create backup
    local backup_file="${build_prop}.bak"
    if ! cp -f "$build_prop" "$backup_file"; then
        echo -e "  ${RED}❌ Error: Backup failed${NORMAL}"
        log_message "ERROR" "Backup failed for $build_prop"
        return 1
    fi
    
    # Process fingerprints for product only
    if [[ "$prop_type" == "product" ]]; then
        local fingerprint_pattern="^ro\.product\.build\.fingerprint="
        local replacement_device="rosemary"
        
        while IFS= read -r line; do
            if [[ "$line" =~ $fingerprint_pattern ]]; then
                local modified_line=$(echo "$line" | sed -E "s|([^/]*/)[^/]*(/.*)|\1${replacement_device}\2|")
                PROPERTY_VALUES["$(echo "$line" | cut -d= -f1)"]="$(echo "$modified_line" | cut -d= -f2-)"
                echo -e "  ${GREEN}✓ Fingerprint modified${NORMAL}"
                log_message "INFO" "Fingerprint modified: $line → $modified_line"
            fi
        done < <(grep -P "$fingerprint_pattern" "$build_prop" 2>/dev/null || true)
    fi
    
    # Read original values
    declare -A ORIGINAL_VALUES
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        local clean_line=$(echo "$line" | sed -E 's/[[:space:]]*#.*//; s/^[[:space:]]+//; s/[[:space:]]+$//')
        
        if [[ "$clean_line" =~ ^([^=[:space:]]+)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
            local prop_name="${BASH_REMATCH[1]}"
            local prop_value="${BASH_REMATCH[2]}"
            prop_value=$(echo "$prop_value" | sed -E 's/^"(.*)"$/\1/; s/^'"'"'(.*)'"'"'$/\1/')
            ORIGINAL_VALUES["$prop_name"]="$prop_value"
        fi
    done < "$backup_file"
    
    # Create temp file
    local temp_file="${build_prop}.tmp"
    cp "$build_prop" "$temp_file"
    
    # Remove previous modifications
    sed -i '/########## Pyro Build Modifications Start ##########/,/########## Pyro Build End ##########/d' "$temp_file"
    
    # Process properties
    local modified_count=0
    local added_count=0
    
    # Add barrier
    echo -e "\n########## Pyro Build Modifications Start ##########\n" >> "$temp_file"
    
    # Process all properties
    for prop_name in "${!PROPERTY_VALUES[@]}"; do
        local new_value="${PROPERTY_VALUES[$prop_name]}"
        
        # Remove existing instances
        sed -i "/^#*[[:space:]]*${prop_name}=/d" "$temp_file"
        
        if [[ -n "${ORIGINAL_VALUES[$prop_name]}" ]]; then
            local original_value="${ORIGINAL_VALUES[$prop_name]}"
            if [[ "$new_value" != "$original_value" ]]; then
                echo "$prop_name=$new_value    # Was: ${original_value}" >> "$temp_file"
                echo -e "  ${GREEN}✓ Modified: $prop_name${NORMAL}"
                ((modified_count++))
                log_message "INFO" "Modified: $prop_name=$new_value (was: ${original_value})"
            else
                echo "$prop_name=$new_value" >> "$temp_file"
                echo -e "  ${YELLOW}✓ Maintained: $prop_name${NORMAL}"
                log_message "INFO" "Maintained: $prop_name=$new_value"
            fi
        else
            echo "$prop_name=$new_value" >> "$temp_file"
            echo -e "  ${BLUE}✓ Added: $prop_name${NORMAL}"
            ((added_count++))
            log_message "INFO" "Added: $prop_name=$new_value"
        fi
    done
    
    echo -e "########## Pyro Build End ##########" >> "$temp_file"
    
    # Replace original file
    local permissions=$(stat -c "%a" "$build_prop")
    local owner=$(stat -c "%U:%G" "$build_prop")
    
    mv "$temp_file" "$build_prop"
    chmod "$permissions" "$build_prop"
    chown "$owner" "$build_prop"
    
    echo -e "${GREEN}✅ ${prop_type^} properties updated! Modified: $modified_count, Added: $added_count${NORMAL}"
    echo -e "  ${CYAN}📦 Backup saved: $backup_file${NORMAL}\n"
    log_message "INFO" "Pyro_${prop_type}_prop_builder completed successfully. Modified: $modified_count, Added: $added_count"
}

run_copier() {
    echo -e "${BOLD}${CYAN}[3/7] Running Pyro Copier...${NORMAL}"
    log_message "INFO" "Starting Pyro_copier"
    
    # Configuration
    declare -A path_map=(
        # EXAMPLES
    #    ["/path/to/source/file1"]="/target/directory1"                        # Regular file copy
    #    ["/path/to/source/folder1"]="/target/directory2:clear"                # Clear target before copying directory
    #    ["/path/to/source/folder2"]="/target/directory3:content"              # Copy folder CONTENTS (not the folder itself)
    #    ["/path/to/source/folder3"]="/target/directory4:clear:content"        # Clear target & copy folder contents
    #    ["/path/to/source/folder4"]="/target/directory5:clear:content:valid"  # Create destination if it doesn't exist

        ["product/etc/device_features"]="$BASE_DIR/product_a/etc/device_features:clear:content" # Needed based on variant
        ["product/etc/displayconfig"]="$BASE_DIR/product_a/etc/displayconfig:clear:content"     # Needed based on variant

        ["product/priv-app/Viper4AndroidFX"]="$BASE_DIR/product_a/priv-app/Viper4AndroidFX:clear:content:valid" # Viper Soundfx
        ["product/etc/permissions/privapp-permissions-dsps.xml"]="$BASE_DIR/product_a/etc/permissions"          # Viperfx perms
        ["system/etc/audio_effects.conf"]="$BASE_DIR/system_a/system/etc"                                       # Viperfx and Dolby configs

        ["product/Moverlay"]="$BASE_DIR/product_a/overlay:content"  # MIUI / HOS1
    #    ["product/Hoverlay"]="$BASE_DIR/product_a/overlay:content" # HOS1.1 / HOS2

        ["product/priv-app/MiuiCamera"]="$BASE_DIR/product_a/priv-app/MiuiCamera:clear:content:valid"     # Stock cam Miui/hos1
    #    ["product/priv-app/MiuiCamerauni"]="$BASE_DIR/product_a/priv-app/MiuiCamera:clear:content"       # Universal cam for hos2
    #    ["product/app/MiuiBiometric"]="$BASE_DIR/product_a/app/MiuiBiometric:clear:content"              # face unlock
        ["product/app/LatinImeGoogle"]="$BASE_DIR/product_a/app/LatinImeGoogle:clear:content:valid"       # Gboard

        # Pyro Icons
        ["product/media/theme/default/com.android.systemui"]="$BASE_DIR/product_a/media/theme/default" # Custom icons, A BIG NO FOR HOS2!

        # CN
    #    ["product/CN"]="$BASE_DIR/product_a:content"
    #    ["product/TW"]="$BASE_DIR/product_a:content"
    #    ["system_ext/priv-app"]="$BASE_DIR/system_ext_a/priv-app:content"
    #    ["product/app/MIUIThemeManager"]="$BASE_DIR/product_a/app/MIUIThemeManager:clear:content"

        # HOS2 
    #    ["system_ext/Apex"]="$BASE_DIR/system_ext_a/apex:content"

        # Touchpad
    #    ["system/usr"]="$BASE_DIR/system_a/system/usr:content"
    )

    # Prompt configuration
    declare -A prompt_messages=(
    #    ["product/CN"]="Install Hyper CN Dialer/MMS if it's a Global A15 Base?"
    #    ["product/TW"]="Install Hyper TW Dialer/MMS if it's a Global A15 Base?"
    #    ["system_ext/priv-app"]="Add CN AuthManager if it's a Global A15 Base??"
    #    ["product/app/MIUIThemeManager"]="Add CN ThemeManager if it's a Global A15 Base??"
    )
    
    # Get fallback destination path
    get_fallback_path() {
        local original_path="$1"
        echo "$original_path" | sed 's|/product_a\b|/product|g; s|/system_a\b|/system|g; s|/system_ext_a\b|/system_ext|g'
    }
    
    # Find working destination path
    find_working_dest() {
        local dest_entry="$1"
        IFS=':' read -r dest_dir flags <<< "$dest_entry"
        
        local has_valid_flag=false
        [[ "$dest_entry" == *":valid"* ]] && has_valid_flag=true
        
        # Check if original destination directory exists
        if [[ -d "$(dirname "$dest_dir")" ]]; then
            echo "$dest_entry"
            return 0
        fi
        
        # Try fallback path
        local fallback_dir=$(get_fallback_path "$dest_dir")
        if [[ -d "$(dirname "$fallback_dir")" ]]; then
            if [[ -n "$flags" ]]; then
                echo "$fallback_dir:$flags"
            else
                echo "$fallback_dir"
            fi
            return 0
        fi
        
        # If :valid flag is present, create the inner path
        if [[ "$has_valid_flag" == true ]]; then
            if [[ -d "$(dirname "$(dirname "$dest_dir")")" ]]; then
                echo -e "  ${BLUE}ℹ️  Creating path: $dest_dir${NORMAL}"
                mkdir -p "$dest_dir"
                echo "$dest_entry"
                return 0
            fi
            
            local fallback_parent=$(dirname "$fallback_dir")
            if [[ -d "$(dirname "$fallback_parent")" ]]; then
                echo -e "  ${BLUE}ℹ️  Creating fallback path: $fallback_dir${NORMAL}"
                mkdir -p "$fallback_dir"
                if [[ -n "$flags" ]]; then
                    echo "$fallback_dir:$flags"
                else
                    echo "$fallback_dir"
                fi
                return 0
            fi
        fi
        
        return 1
    }
    
    # Update privapp XML permissions
    update_privapp_xml() {
        local xml_file="$BASE_DIR/product_a/etc/permissions/privapp-permissions-product.xml"
        
        if [[ ! -f "$xml_file" ]]; then
            local fallback_xml=$(get_fallback_path "$xml_file")
            if [[ -f "$fallback_xml" ]]; then
                xml_file="$fallback_xml"
            else
                echo -e "  ${YELLOW}⚠️  XML file not found: $xml_file${NORMAL}"
                return 1
            fi
        fi
        
        if grep -q '<privapp-permissions package="com.android.contacts">' "$xml_file"; then
            echo -e "  ${YELLOW}ℹ️  Permissions already exist in XML${NORMAL}"
            return 0
        fi
        
        echo -e "  ${GREEN}✓ Adding permissions to XML...${NORMAL}"
        
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
        
        sed -i -e '/<permissions>/r '"$tmpfile" "$xml_file"
        rm "$tmpfile"
        
        echo -e "  ${GREEN}✓ XML permissions successfully updated${NORMAL}"
        log_message "INFO" "XML permissions updated in $xml_file"
    }
    
    # Parse targets and prepare operations
    declare -A clear_dirs=()
    declare -A content_sources=()
    declare -A working_destinations=()
    local xml_updated=false
    local errors=0
    local warnings=0
    
    for source in "${!path_map[@]}"; do
        local dest_entry="${path_map[$source]}"
        
        if working_dest=$(find_working_dest "$dest_entry"); then
            working_destinations["$source"]="$working_dest"
            
            IFS=':' read -r dest_dir flags <<< "$working_dest"
            
            [[ "$working_dest" == *":clear"* ]] && clear_dirs["$dest_dir"]=1
            [[ "$working_dest" == *":content"* ]] && content_sources["$source"]=1
        else
            echo -e "  ${YELLOW}⚠️  No valid destination found for $source${NORMAL}"
            ((warnings++))
            log_message "WARNING" "No valid destination found for $source"
        fi
    done
    
    # Clear target directories
    echo -e "  ${CYAN}Preparing target directories...${NORMAL}"
    for dir in "${!clear_dirs[@]}"; do
        echo -e "    ${YELLOW}Clearing: $dir${NORMAL}"
        mkdir -p "$dir"
        find "$dir" -mindepth 1 -delete 2>/dev/null || true
        log_message "INFO" "Cleared directory: $dir"
    done
    
    # Copy operations
    echo -e "  ${CYAN}Copying components...${NORMAL}"
    for source in "${!working_destinations[@]}"; do
        local dest_entry="${working_destinations[$source]}"
        IFS=':' read -r dest_dir flags <<< "$dest_entry"
        local item_name=$(basename "$source")
        
        # Validate source exists
        if [[ ! -e "$source" ]]; then
            echo -e "    ${RED}❌ Source missing: $source${NORMAL}"
            ((errors++))
            log_message "ERROR" "Source missing: $source"
            continue
        fi
        
        # Update XML once per session if needed
        if [[ "$source" == *"privapp-permissions-dsps.xml" ]] && ! $xml_updated; then
            update_privapp_xml
            xml_updated=true
        fi
        
        # Copy operation
        mkdir -p "$dest_dir"
        local perm_path
        
        if [[ -d "$source" && -v "content_sources[$source]" ]]; then
            echo -e "    ${GREEN}✓ Copying contents: $item_name → $dest_dir/${NORMAL}"
            if cp -r "$source/." "$dest_dir" 2>/dev/null; then
                perm_path="$dest_dir"
                log_message "INFO" "Copied contents: $source → $dest_dir"
            else
                echo -e "      ${RED}❌ Failed to copy contents${NORMAL}"
                ((errors++))
                log_message "ERROR" "Failed to copy contents: $source → $dest_dir"
                continue
            fi
        else
            local dest_path="$dest_dir/$item_name"
            if [[ -d "$source" ]]; then
                echo -e "    ${GREEN}✓ Copying directory: $item_name → $dest_dir/${NORMAL}"
                if cp -r "$source" "$dest_dir"; then
                    perm_path="$dest_path"
                    log_message "INFO" "Copied directory: $source → $dest_dir"
                else
                    echo -e "      ${RED}❌ Directory copy failed${NORMAL}"
                    ((errors++))
                    log_message "ERROR" "Directory copy failed: $source → $dest_dir"
                    continue
                fi
            else
                echo -e "    ${GREEN}✓ Copying file: $item_name → $dest_dir/${NORMAL}"
                if cp "$source" "$dest_dir"; then
                    perm_path="$dest_path"
                    log_message "INFO" "Copied file: $source → $dest_dir"
                else
                    echo -e "      ${RED}❌ File copy failed${NORMAL}"
                    ((errors++))
                    log_message "ERROR" "File copy failed: $source → $dest_dir"
                    continue
                fi
            fi
        fi
        
        # Set permissions
        if [[ -e "$perm_path" ]]; then
            find "$perm_path" -type d -exec chmod 755 {} + 2>/dev/null
            find "$perm_path" -type f -exec chmod 644 {} + 2>/dev/null
        fi
    done
    
    # Final permission sweep
    echo -e "  ${CYAN}Finalizing permissions...${NORMAL}"
    find "$BASE_DIR" -type d -exec chmod 755 {} + 2>/dev/null
    find "$BASE_DIR" -type f -exec chmod 644 {} + 2>/dev/null
    
    if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
        echo -e "${GREEN}✅ Copier completed successfully! XML updated: $xml_updated${NORMAL}\n"
    else
        echo -e "${YELLOW}⚠️  Copier completed with $errors error(s) and $warnings warning(s). XML updated: $xml_updated${NORMAL}\n"
    fi
    
    log_message "INFO" "Pyro_copier completed. Errors: $errors, Warnings: $warnings, XML updated: $xml_updated"
}

run_miext_mover() {
    echo -e "${BOLD}${CYAN}[4/7] Running Pyro MI_EXT Mover...${NORMAL}"
    log_message "INFO" "Starting Pyro_miext_mover"
    
    # Configuration
    declare -A path_map=(
        ["$BASE_DIR/mi_ext_a/product"]="$BASE_DIR/product_a:content"
        ["$BASE_DIR/mi_ext_a/system"]="$BASE_DIR/system_a/system:content"
        ["$BASE_DIR/mi_ext_a/system_ext"]="$BASE_DIR/system_ext_a:content"
    )
    
    # Try fallback paths
    declare -A fallback_map=(
        ["$BASE_DIR/mi_ext/product"]="$BASE_DIR/product:content"
        ["$BASE_DIR/mi_ext/system"]="$BASE_DIR/system/system:content"
        ["$BASE_DIR/mi_ext/system_ext"]="$BASE_DIR/system_ext:content"
    )
    
    local moved_count=0
    local errors=0
    
    # Process primary paths first, then fallbacks
    for source_base in "$BASE_DIR/mi_ext_a" "$BASE_DIR/mi_ext"; do
        [[ ! -d "$source_base" ]] && continue
        
        local current_map
        if [[ "$source_base" == *"mi_ext_a" ]]; then
            declare -n current_map=path_map
        else
            declare -n current_map=fallback_map
        fi
        
        for source in "${!current_map[@]}"; do
            [[ ! -e "$source" ]] && continue
            
            local dest_entry="${current_map[$source]}"
            IFS=':' read -r dest_dir flags <<< "$dest_entry"
            
            echo -e "  ${GREEN}✓ Moving contents: $(basename "$source") → $dest_dir/${NORMAL}"
            
            mkdir -p "$dest_dir"
            if cp -r "$source"/. "$dest_dir" 2>/dev/null; then
                rm -rf "$source"
                ((moved_count++))
                log_message "INFO" "Moved contents: $source → $dest_dir"
                
                # Set permissions
                find "$dest_dir" -type d -exec chmod 755 {} + 2>/dev/null
                find "$dest_dir" -type f -exec chmod 644 {} + 2>/dev/null
            else
                echo -e "    ${RED}❌ Failed to move contents${NORMAL}"
                ((errors++))
                log_message "ERROR" "Failed to move contents: $source → $dest_dir"
            fi
        done
        
        unset -n current_map
        break  # Only process the first available base directory
    done
    
    if [[ $moved_count -gt 0 ]]; then
        echo -e "${GREEN}✅ MI_EXT mover completed! Moved $moved_count items.${NORMAL}\n"
    else
        echo -e "${YELLOW}⚠️  No mi_ext directories found to move.${NORMAL}\n"
    fi
    
    log_message "INFO" "Pyro_miext_mover completed. Moved: $moved_count, Errors: $errors"
}

run_super_packer() {
    echo -e "${BOLD}${CYAN}[8/8] Running Super Packer 4000...${NORMAL}"
    log_message "INFO" "Starting Super_packer_4000"
    
    # Configuration
    local METADATA_SIZE=65536
    local SUPER_NAME="super"
    local METADATA_SLOTS=3
    local DEVICE_SIZE=9126805504
    local OUTPUT_IMAGE="$OUTPUT_DIR/super.img"
    local GROUP_A_SIZE=9124708352
    local GROUP_B_SIZE=9124708352
    
    # File pairs for moving (source:target)
    local FILES=(
        "vendor_a.new.img:vendor_a.img"
        "mi_ext.new.img:mi_ext_a.img"
        "product.new.img:product_a.img"
        "system.new.img:system_a.img"
        "system_ext.new.img:system_ext_a.img"
        "mi_ext_a.new.img:mi_ext_a.img"
        "product_a.new.img:product_a.img"
        "system_a.new.img:system_a.img"
        "system_ext_a.new.img:system_ext_a.img"
    )
    
    # Phase 1: Move/Prepare Partition Images
    echo -e "  ${CYAN}Phase 1: Preparing partition images...${NORMAL}"
    
    # Validate directories
    if [[ ! -d "$SUPER_SOURCE_DIR" ]]; then
        echo -e "  ${RED}❌ Missing source directory: $SUPER_SOURCE_DIR${NORMAL}"
        log_message "ERROR" "Missing source directory: $SUPER_SOURCE_DIR"
        return 1
    fi
    
    if [[ ! -d "$SUPER_TARGET_DIR" ]]; then
        echo -e "  ${RED}❌ Missing target directory: $SUPER_TARGET_DIR${NORMAL}"
        log_message "ERROR" "Missing target directory: $SUPER_TARGET_DIR"
        return 1
    fi
    
    # Check available space
    local source_size=$(du -bs "$SUPER_SOURCE_DIR" 2>/dev/null | cut -f1 || echo "0")
    local avail_space=$(df -B1 "$SUPER_TARGET_DIR" 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")
    
    if [[ $source_size -gt $avail_space && $avail_space -ne 0 ]]; then
        echo -e "  ${RED}❌ Not enough space in $SUPER_TARGET_DIR (Needed: $((source_size/1024/1024))MB)${NORMAL}"
        log_message "ERROR" "Insufficient space in $SUPER_TARGET_DIR"
        return 1
    fi
    
    # Move files
    local moved_files=0
    for pair in "${FILES[@]}"; do
        IFS=':' read -r src tgt <<< "$pair"
        local src_path="$SUPER_SOURCE_DIR/$src"
        local tgt_path="$SUPER_TARGET_DIR/$tgt"
        
        if [[ ! -f "$src_path" ]]; then
            echo -e "    ${YELLOW}⚠️ Skipping missing: $src_path${NORMAL}"
            continue
        fi
        
        # Remove old target file if exists
        if [[ -f "$tgt_path" ]]; then
            if ! rm -f "$tgt_path"; then
                echo -e "    ${RED}❌ Failed to remove old file: $tgt_path${NORMAL}"
                log_message "ERROR" "Failed to remove old file: $tgt_path"
                return 1
            fi
        fi
        
        # Move file
        if mv "$src_path" "$tgt_path" 2>/dev/null; then
            echo -e "    ${GREEN}✓ Moved: $src → $tgt${NORMAL}"
            ((moved_files++))
            log_message "INFO" "Moved: $src → $tgt"
        else
            echo -e "    ${RED}❌ Failed to move: $src → $tgt${NORMAL}"
            log_message "ERROR" "Failed to move: $src → $tgt"
            return 1
        fi
    done
    
    echo -e "  ${GREEN}✅ Phase 1 Complete: $moved_files partition images prepared${NORMAL}"
    
    # Phase 2: Build Sparse Super Image
    echo -e "  ${CYAN}Phase 2: Building sparse super image...${NORMAL}"
    
    # Define image paths
    local MI_EXT_A_IMG="$SUPER_TARGET_DIR/mi_ext_a.img"
    local PRODUCT_A_IMG="$SUPER_TARGET_DIR/product_a.img"
    local SYSTEM_A_IMG="$SUPER_TARGET_DIR/system_a.img"
    local SYSTEM_EXT_A_IMG="$SUPER_TARGET_DIR/system_ext_a.img"
    local VENDOR_A_IMG="$SUPER_TARGET_DIR/vendor_a.img"
    
    # Verify critical images exist
    local REQUIRED_IMAGES=("$MI_EXT_A_IMG" "$PRODUCT_A_IMG" "$SYSTEM_A_IMG" "$SYSTEM_EXT_A_IMG" "$VENDOR_A_IMG")
    local missing_images=0
    
    for img in "${REQUIRED_IMAGES[@]}"; do
        if [[ ! -f "$img" ]]; then
            echo -e "    ${RED}❌ Missing required image: $img${NORMAL}"
            ((missing_images++))
            log_message "ERROR" "Missing required image: $img"
        fi
    done
    
    if [[ $missing_images -gt 0 ]]; then
        echo -e "  ${RED}❌ Cannot proceed: $missing_images required images missing${NORMAL}"
        return 1
    fi
    
    # Get sizes for each image
    local MI_EXT_A_SIZE=$(stat -c%s "$MI_EXT_A_IMG" 2>/dev/null || echo "0")
    local PRODUCT_A_SIZE=$(stat -c%s "$PRODUCT_A_IMG" 2>/dev/null || echo "0")
    local SYSTEM_A_SIZE=$(stat -c%s "$SYSTEM_A_IMG" 2>/dev/null || echo "0")
    local SYSTEM_EXT_A_SIZE=$(stat -c%s "$SYSTEM_EXT_A_IMG" 2>/dev/null || echo "0")
    local VENDOR_A_SIZE=$(stat -c%s "$VENDOR_A_IMG" 2>/dev/null || echo "0")
    
    echo -e "    ${BLUE}📦 Building super image (sparse format)...${NORMAL}"
    echo -e "    ${CYAN}   MI_EXT_A: $(( MI_EXT_A_SIZE / 1024 / 1024 ))MB${NORMAL}"
    echo -e "    ${CYAN}   PRODUCT_A: $(( PRODUCT_A_SIZE / 1024 / 1024 ))MB${NORMAL}"
    echo -e "    ${CYAN}   SYSTEM_A: $(( SYSTEM_A_SIZE / 1024 / 1024 ))MB${NORMAL}"
    echo -e "    ${CYAN}   SYSTEM_EXT_A: $(( SYSTEM_EXT_A_SIZE / 1024 / 1024 ))MB${NORMAL}"
    echo -e "    ${CYAN}   VENDOR_A: $(( VENDOR_A_SIZE / 1024 / 1024 ))MB${NORMAL}"
    
    # Check if lpmake exists
    if ! command -v lpmake >/dev/null 2>&1; then
        echo -e "  ${RED}❌ Error: lpmake command not found. Please install Android build tools.${NORMAL}"
        log_message "ERROR" "lpmake command not found"
        return 1
    fi
    
    # Build super image
    if lpmake \
        --metadata-size "$METADATA_SIZE" \
        --super-name "$SUPER_NAME" \
        --metadata-slots "$METADATA_SLOTS" \
        --device "$SUPER_NAME:$DEVICE_SIZE" \
        --group qti_dynamic_partitions_a:"$GROUP_A_SIZE" \
        --group qti_dynamic_partitions_b:"$GROUP_B_SIZE" \
        --partition=mi_ext_a:none:"$MI_EXT_A_SIZE":qti_dynamic_partitions_a \
        --image=mi_ext_a="$MI_EXT_A_IMG" \
        --partition=mi_ext_b:none:0:qti_dynamic_partitions_b \
        --partition=product_a:none:"$PRODUCT_A_SIZE":qti_dynamic_partitions_a \
        --image=product_a="$PRODUCT_A_IMG" \
        --partition=product_b:none:0:qti_dynamic_partitions_b \
        --partition=system_a:none:"$SYSTEM_A_SIZE":qti_dynamic_partitions_a \
        --image=system_a="$SYSTEM_A_IMG" \
        --partition=system_b:none:0:qti_dynamic_partitions_b \
        --partition=system_ext_a:none:"$SYSTEM_EXT_A_SIZE":qti_dynamic_partitions_a \
        --image=system_ext_a="$SYSTEM_EXT_A_IMG" \
        --partition=system_ext_b:none:0:qti_dynamic_partitions_b \
        --partition=vendor_a:none:"$VENDOR_A_SIZE":qti_dynamic_partitions_a \
        --image=vendor_a="$VENDOR_A_IMG" \
        --partition=vendor_b:none:0:qti_dynamic_partitions_b \
        --virtual-ab \
        --sparse \
        --output "$OUTPUT_IMAGE" 2>/dev/null; then
        
        # Set permissions
        chmod 660 "$OUTPUT_IMAGE" 2>/dev/null || {
            echo -e "    ${YELLOW}⚠️ Warning: Failed to set permissions on $OUTPUT_IMAGE${NORMAL}"
        }
        
        local output_size=$(stat -c%s "$OUTPUT_IMAGE" 2>/dev/null || echo "0")
        echo -e "  ${GREEN}✅ Phase 2 Complete: Sparse super image generated${NORMAL}"
        echo -e "    ${BOLD}${GREEN}📁 Output: $OUTPUT_IMAGE${NORMAL}"
        echo -e "    ${CYAN}📊 Size: $(( output_size / 1024 / 1024 ))MB${NORMAL}\n"
        
        log_message "INFO" "Super image generated successfully: $OUTPUT_IMAGE ($(( output_size / 1024 / 1024 ))MB)"
        return 0
    else
        echo -e "  ${RED}❌ lpmake failed to generate super image${NORMAL}"
        log_message "ERROR" "lpmake failed to generate super image"
        return 1
    fi
}

get_user_selection() {
    local prompt="$1"
    local choice
    
    while true; do
        read -p "$prompt" choice
        case "${choice,,}" in
            a|all|s|specific|select|q|quit|exit|y|yes|n|no) 
                echo "$choice"
                return 0 
                ;;
            "") 
                echo -e "${RED}Please enter a choice.${NORMAL}" 
                ;;
            *) 
                echo -e "${RED}Invalid choice. Please try again.${NORMAL}" 
                ;;
        esac
    done
}

select_specific_scripts() {
    local selected_scripts=()
    
    echo -e "\n${BOLD}${BLUE}Select scripts to run (comma-separated, e.g., 1,3,5):${NORMAL}"
    echo -e "${BLUE}────────────────────────────────────────────────────────────${NORMAL}"
    
    for i in {1..8}; do
        IFS='|' read -r script_name description <<< "${SCRIPTS[$i]}"
        echo -e "  ${YELLOW}[$i]${NORMAL} ${BOLD}$script_name${NORMAL}"
    done
    
    echo
    while true; do
        read -p "Enter your selection: " selection
        
        # Validate and parse selection
        if [[ "$selection" =~ ^[1-8](,[1-8])*$ ]]; then
            IFS=',' read -ra selected_scripts <<< "$selection"
            
            # Remove duplicates and sort
            selected_scripts=($(printf '%s\n' "${selected_scripts[@]}" | sort -u))
            
            echo -e "\n${GREEN}Selected scripts:${NORMAL}"
            for script_num in "${selected_scripts[@]}"; do
                IFS='|' read -r script_name description <<< "${SCRIPTS[$script_num]}"
                echo -e "  ${YELLOW}[$script_num]${NORMAL} ${BOLD}$script_name${NORMAL}"
            done
            
            local confirm
            echo
            while true; do
                read -p "Proceed with these scripts? [y/N]: " confirm
                case "${confirm,,}" in
                    y|yes) break 2 ;;
                    n|no|"") 
                        echo -e "${YELLOW}Selection cancelled. Please choose again.${NORMAL}\n"
                        break 
                        ;;
                    *) echo -e "${RED}Please enter y or n.${NORMAL}" ;;
                esac
            done
        else
            echo -e "${RED}Invalid format. Use comma-separated numbers (1-8), e.g., 1,3,5${NORMAL}"
        fi
    done
    
    echo "${selected_scripts[@]}"
}

run_selected_scripts() {
    local scripts_to_run=("$@")
    local total_scripts=${#scripts_to_run[@]}
    local current_step=0
    
    echo -e "${BOLD}${PURPLE}Starting PyroOS build sequence ($total_scripts scripts)...${NORMAL}\n"
    log_message "INFO" "Starting PyroOS build sequence with $total_scripts scripts"
    
    for script_num in "${scripts_to_run[@]}"; do
        ((current_step++))
        
        case "$script_num" in
            1) run_debloater ;;
            2) run_prop_builder "product" "$BASE_DIR/product_a/etc/build.prop" "$current_step" "$total_scripts" ;;
            3) run_copier ;;
            4) run_miext_mover ;;
            5) run_prop_builder "miext" "$BASE_DIR/mi_ext_a/etc/build.prop" "$current_step" "$total_scripts" ;;
            6) run_prop_builder "system" "$BASE_DIR/system_a/system/build.prop" "$current_step" "$total_scripts" ;;
            7) run_prop_builder "system_ext" "$BASE_DIR/system_ext_a/etc/build.prop" "$current_step" "$total_scripts" ;;
            8) run_super_packer ;;
        esac
    done
    
    echo -e "${BOLD}${GREEN}🎉 PyroOS build sequence completed successfully!${NORMAL}"
    echo -e "${CYAN}📋 Check the log file for detailed information: $LOG_FILE${NORMAL}\n"
    log_message "INFO" "PyroOS build sequence completed successfully"
}

main() {
    print_header
    validate_environment
    
    while true; do
        print_menu
        echo
        
        local choice
        while true; do
            read -p "Enter your choice [A/S/Q]: " choice
            case "${choice,,}" in
                a|all)
                    echo -e "\n${BOLD}${GREEN}Running ALL scripts in sequence...${NORMAL}\n"
                    run_selected_scripts {1..8}
                    return 0
                    ;;
                s|specific|select)
                    local selected=($(select_specific_scripts))
                    if [[ ${#selected[@]} -gt 0 ]]; then
                        run_selected_scripts "${selected[@]}"
                    fi
                    return 0
                    ;;
                q|quit|exit)
                    echo -e "${BOLD}${YELLOW}Goodbye! 👋${NORMAL}"
                    exit 0
                    ;;
                "")
                    echo -e "${RED}Please enter a choice.${NORMAL}"
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Please enter A, S, or Q.${NORMAL}"
                    ;;
            esac
        done
    done
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi