#!/usr/bin/env bash

# PyroOS Combined Script
# Combines all Pyro modification scripts with interactive menu system
# Author: Arsham
# License: MIT

# Configuration
BASE_DIR="UKL/UnpackerSystem"
SUPER_SOURCE_DIR="UKL/UnpackerSystem"
SUPER_TARGET_DIR="UKL/UnpackerSuper"
OUTPUT_DIR="output"
LOG_FILE="pyro_boom_$(date +%Y%m%d_%H%M%S).log"

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
    [8]="Pyro_file_appender|Append custom lines to specific files"
    [9]="Pyro_file_remover|Remove specific files and folders"
    [10]="Pyro_vendor_prop_builder|Modify vendor build properties"
    [11]="Pyro_super_packer|Build sparse super image from partitions"
)

# Function definitions
print_header() {
    clear

    # Truecolor fiery gradient
    RED="\033[38;2;255;80;80m"
    ORANGE="\033[38;2;255;140;0m"
    YELLOW="\033[38;2;255;215;0m"
    CYAN="\033[38;2;100;200;255m"
    RESET="\033[0m"
    BOLD="\033[1m"

    echo -e "${RED}${BOLD}"
    echo -e "${RED}   ██████╗ ██╗   ██╗██████╗  ██████╗     ${RESET} ██████╗ ███████╗"
    echo -e "${RED}   ██╔══██╗╚██╗ ██╔╝██╔══██╗██╔═══██╗    ${RESET}██╔═══██╗██╔════╝"
    echo -e "${RED}   ██████╔╝ ╚████╔╝ ██████╔╝██║   ██║    ${RESET}██║   ██║███████╗"
    echo -e "${RED}   ██╔═══╝   ╚██╔╝  ██╔══██╗██║   ██║    ${RESET}██║   ██║╚════██║"
    echo -e "${RED}   ██║        ██║   ██║  ██║╚██████╔╝    ${RESET}╚██████╔╝███████║"
    echo -e "${RED}   ╚═╝        ╚═╝   ╚═╝  ╚═╝ ╚═════╝     ${RESET} ╚═════╝ ╚══════╝"${RESET}
    echo -e "╔════════════════════════════════════════════════════════════════════════╗"${RESET} 
    echo -e "║${YELLOW}  🔥 PyroOS   |   Build Suite v2.0${RESET}                                      ║"
    echo -e "╠════════════════════════════════════════════════════════════════════════╣"${RESET} 
    echo -e "║${CYAN}${BOLD} 💎 Credits${RESET}                                                             ║"
    echo -e "║  ${BOLD} 🚀 @ArshamEbr         - ${RESET}Creator of the automation script             ║"
    echo -e "║  ${BOLD} 📚 @NEESCHAL_3        - ${RESET}Guided me in ROM knowledge                   ║"
    echo -e "║  ${BOLD} 📚 @fahimfaisaladitto - ${RESET}Gave the idea to make it more user-friendly  ║"
    echo -e "║  ${BOLD} 🌟 @PapaAlpha32       - ${RESET}Started my ROM porting journey               ║"
    echo -e "╚════════════════════════════════════════════════════════════════════════╝${RESET}"

    sleep 1

    echo -e "${CYAN}${BOLD}📂 Base Directory:   ${RESET}$BASE_DIR"
    echo -e "${CYAN}${BOLD}📦 Super Target:     ${RESET}$SUPER_TARGET_DIR"
    echo -e "${CYAN}${BOLD}📤 Output Directory: ${RESET}$OUTPUT_DIR"
    echo -e "${CYAN}${BOLD}📝 Log File:         ${RESET}$LOG_FILE\n"
}

print_menu() {
    echo -e "${BOLD}${BLUE}Available Scripts:${NORMAL}"
    echo -e "${BLUE}────────────────────────────────────────────────────────────${NORMAL}"
    
    for i in {1..11}; do
        IFS='|' read -r script_name description <<< "${SCRIPTS[$i]}"
        echo -e "  ${RED}[$i]${NORMAL} ${BOLD}$script_name${NORMAL}"
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
    echo -e "${BOLD}${CYAN}[1/9] Running Pyro Debloater...${NORMAL}"
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
        "MIUICloudBackup" "MiGameCenterSDKService"
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
        "MIUICleanMaster" "Health" "BaiduIME" "DownloadProviderUI" "MiService"
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
        "CrossDeviceServices" "AppEnabler" "AppSelector" "Joyose" "WMService"
        "MIUIPersonalAssistantPhoneMIUI15" "MIUIMirror" "system"
        "XiaoaiEdgeEngine" "MITSMClient" "MaintenanceMode" "MetokNLP"
        "MIUIVpnSdkManager" "GoogleFeedback" "dtag-appenabler" "GFManagerForCit"
        "GFTestForCit" "LCCit" "MIBrowserGlobal_removable"
    )
# "AndroidSystemIntelligence_Infrastructure" NO
# "MiLauncherGlobal" NO for POCO

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

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
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
    local -a COMMENT_OUT_PROPS
    
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
                ["ro.product.product.name"]="${DEVICE_CODENAME:-rosemary}"
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
                ["ro.product.mod_device"]="${DEVICE_CODENAME:-rosemary}"
                ["persist.sys.app_dexfile_preload.enable"]="false"
                ["persist.sys.usap_pool_enabled"]="false"
                ["persist.sys.dynamic_usap_enabled"]="false"
                ["persist.sys.spc.proc_restart_enable"]="false"
                ["persist.sys.preload.enable"]="true" # not sure
                ["persist.sys.precache.enable"]="false"
                ["persist.sys.prestart.proc"]="false"
                ["persist.sys.prestart.feedback.enable"]="false"
                ["persist.sys.performance.appLaunchPreload.enable"]="false"
                ["persist.sys.smartcache.enable"]="false"
                ["persist.sys.art_startup_class_preload.enable"]="false"
            )
            COMMENT_OUT_PROPS=(
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
                "persist.sys.adoptable"
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
                ####################################
            #    ["ro.product.brand"]="Redmi"
                ## ## ## ## ##
                ["ro.boot.verifiedbootstate"]="green"
                ["vendor.boot.verifiedbootstate"]="green"
                ["vendor.boot.vbmeta.device_state"]="locked"
                ["ro.boot.veritymode"]="enforcing"
                ["ro.boot.vbmeta.device_state"]="locked"
                ["ro.boot.flash.locked"]="1"
            )
            COMMENT_OUT_PROPS=(
            )
            ;;
        "system_ext")
            PROPERTY_VALUES=(
                ["ro.surface_flinger.supports_background_blur"]="1"
                ["persist.sys.miui_scout_enable"]="true"
            )
            COMMENT_OUT_PROPS=(
            )
            ;;
        "miext")
            PROPERTY_VALUES=(
                ["ro.product.mod_device"]="${DEVICE_CODENAME:-rosemary}"
            )
            COMMENT_OUT_PROPS=(
                "ro.microsoft.onedrive_partner_code"
            )
            ;;
        "vendor")
            PROPERTY_VALUES=( # DEVICE RELATED!
                # Enable Vulkan rendering for better GPU performance
                ["ro.hwui.use_vulkan"]="1"
                
            #    ["ro.product.vendor.brand"]="Redmi"
                
                # certain props by kashi
                ["ro.surface_flinger.use_color_management"]="true"
                ["ro.surface_flinger.protected_contents"]="true"
                ["ro.surface_flinger.use_content_detection_for_refresh_rate"]="true"
                ["ro.surface_flinger.set_touch_timer_ms"]="200"
                ["ro.surface_flinger.force_hwc_copy_for_virtual_displays"]="true"
                ["ro.surface_flinger.max_frame_buffer_acquired_buffers"]="3" # can be 4
                ["ro.surface_flinger.max_virtual_display_dimension"]="4096"
                ["ro.surface_flinger.supports_background_blur"]="1"
                ["ro.surface_flinger.has_wide_color_display"]="true"
                ["ro.surface_flinger.has_HDR_display"]="true"
                ["ro.surface_flinger.wcg_composition_dataspace"]="143261696"
                ["ro.surface_flinger.enable_frame_rate_override"]="false"
                
                ["persist.sys.miui_animator_sched.bigcores"]="6-7"
                ["persist.sys.miui_animator_sched.sched_threads"]="2"
                ["persist.sys.miui.sf_cores"]="4-7"
                ["persist.sys.miui_animator_sched.big_prime_cores"]="6-7"
                ["persist.sys.enable_templimit"]="true"
                ["persist.vendor.display.miui.composer_boost"]="4-7"
                ["persist.sys.smartpower.intercept.enable"]="true"
                ["persist.sys.miui_sptm.enable"]="true"
                ["persist.sys.miui_sptm.enable_pl_type"]="3"
                ["persist.sys.preload.enable"]="true"
                ["persist.sys.minfree_def"]="73728,92160,110592,154832,482560,579072"
                ["persist.sys.minfree_6g"]="73728,92160,110592,258048,663552,903168"
                ["persist.sys.minfree_8g"]="73728,92160,110592,387072,1105920,1451520"
                
                # Force GPU rendering for 2D operations (reduces CPU load)
                ["debug.sf.hw"]="1"
                ["persist.sys.ui.hw"]="1"
                
                # Disable debugging for SurfaceFlinger (improves UI rendering)
                ["debug.sf.enable_gl_backpressure"]="0"
                
                # Increase JIT cache size for faster app launches
                ["dalvik.vm.jit.codecachesize"]="64"
                
                # Disable kernel error checking (reduces overhead)
                ["ro.kernel.android.checkjni"]="0"
                ["ro.kernel.checkjni"]="0"
                
                # Enable GPU acceleration for UI transitions
                ["debug.sf.enable_hwc_vds"]="1"
                
                # Optimize SurfaceFlinger for smoother animations
                ["debug.sf.latch_unsignaled"]="1"
                ["ro.surface_flinger.max_frame_buffer_acquired_buffers"]="3"
                
                # Reduce background process limit to save battery
                ["ro.sys.fw.bg_apps_limit"]="16"
                
                # Enable aggressive doze mode for better standby battery life
                ["ro.config.hw_power_saving"]="1"
                ["ro.config.hw_fast_dormancy"]="1"
                
                # Disable unnecessary logging (reduces CPU and I/O overhead)
                ["persist.log.tag"]="W"
                ["persist.log.tag.ImsService"]="W"
                ["persist.log.tag.RIL"]="W"
                ["persist.log.tag.RfxMainThread"]="W"
                ["persist.log.tag.RILC"]="W"
                
                # Optimize Wi-Fi and Bluetooth for power efficiency
                ["wifi.supplicant_scan_interval"]="180"
                ["ro.ril.disable.power.collapse"]="0"
                ["persist.bluetooth.enable_energy_info"]="1"
                
                # Reduce CPU usage during idle
                ["power_supply.wakeup"]="enable"
                ["ro.ril.power_collapse"]="1"
                
                # Disable animation scaling (reduces GPU/CPU load)
                ["persist.sys.disable.animations"]="1"
                
                # Optimize CPU governor for better battery life
                ["persist.sys.cpu.gov"]="interactive"
                ["persist.sys.cpu.gov.tune"]="1"
                
                # Optimize Low Memory Killer (LMK) settings
                ["ro.lmk.thrashing_limit"]="50"
                
                # Battery & Charging
                ["persist.vendor.battery.health"]="1"
                ["persist.vendor.accelerate.charge"]="1"
                ["persist.vendor.night.charge"]="1"
                ["persist.sys.power.default.powermode"]="1"
                
                # Audio Enhancements
                ["ro.vendor.audio.aiasst.support"]="true"
                ["ro.vendor.audio.sfx.earadj"]="true"
                ["ro.vendor.audio.sfx.scenario"]="true"
                ["ro.vendor.audio.scenario.support"]="true"
                ["ro.vendor.audio.voice.change.support"]="true"
                ["ro.vendor.audio.surround.support"]="true"
                ["ro.vendor.audio.vocal.support"]="true"
                ["ro.vendor.audio.playbackcapture.screen"]="1"
                ["ro.vendor.audio.sfx.harmankardon"]="1"
                ["ro.vendor.audio.feature.spatial"]="7"
                ["ro.vendor.audio.bass.enhancer.enable"]="true"
                ["ro.vendor.audio.virtualizer.enable"]="true"
                ["ro.vendor.audio.volume.modeler.enable"]="true"
                ["ro.vendor.audio.speaker.surround.boost"]="110"
                ["ro.vendor.audio.voice.change.youme.support"]="true"
                ["ro.vendor.audio.voice.volume.boost"]="none"
                
                # MediaTek Hardware
                ["ro.vendor.mtk_pq_support"]="2"
                
                # Disable unnecessary MediaTek logging
                ["persist.log.tag.MtkDct"]="W"
                ["persist.log.tag.MtkDc"]="W"
                ["persist.log.tag.MtkDcc"]="W"
                
                # Aod
                ["ro.vendor.sf.detect.aod.enable"]="true"
                
                # Unverified/Device-Specific
                ["persist.vendor.vcb.enable"]="true"
                ["persist.vendor.vcb.ability"]="true"
                ["ro.com.google.ime.theme_dir"]=""
                ["ro.com.google.ime.theme_file"]=""
                ["ro.se.type"]="eSE,HCE,UICC"
                ["ro.vendor.video_box.version"]="2"
                
                # PyroOS-Specific
                ["persist.miui.miperf.enable"]="1"
                ["persist.sys.enable_miui_booster"]="1"
                ["debug.game.video.speed"]="1"
                ["debug.game.video.support"]="1"
                ["ro.vendor.media.video.frc.support"]="true"
                ["ro.vendor.media.video.vpp.support"]="true"
                ["debug.config.media.video.frc.support"]="true"
                ["debug.config.media.video.aie.support"]="true"
                ["debug.config.media.video.ais.support"]="true"
                ["vendor.perf.framepacing.enable"]="true"
                
                # Dolby Pro Max
                ["persist.vendor.audio.misound.disable"]="true"
                ["ro.vendor.audio.dolby.dax.support"]="true"
                ["ro.vendor.audio.hifi"]="true"
                ["ro.vendor.audio.game.mode"]="true"
                ["ro.vendor.audio.sos"]="true"
                ["ro.vendor.audio.soundtrigger.mtk.pangaea"]="1"
                ["ro.vendor.audio.soundtrigger.xiaomievent"]="1"
                ["ro.vendor.audio.soundtrigger.wakeupword"]="5"
                ["ro.vendor.audio.soundtrigger.mtk.split_training"]="1"
                ["ro.vendor.dolby.dax.version"]="DAX3_3.6.0.12_r1"
                ["ro.vendor.audio.5k"]="true"
                ["ro.audio.monitorRotation"]="true"
                ["ro.vendor.audio.dolby.vision.support"]="true"
                ["ro.vendor.display.dolbyvision.support"]="true"
                ["debug.config.media.video.dolby_vision_suports"]="true"
                
                # PQ Pro Max
                ["vendor.debug.pq.dshp.en"]="0"
                ["vendor.debug.pq.shp.en"]="0"
                ["persist.vendor.sys.pq.iso.shp.en"]="0"
                ["persist.vendor.sys.pq.ultrares.en"]="0"
                ["persist.vendor.sys.pq.shp.idx"]="0"
                ["persist.vendor.sys.pq.shp.strength"]="0"
                ["persist.vendor.sys.pq.shp.step"]="0"
                ["persist.vendor.sys.pq.dispshp.strength"]="0"
                ["persist.vendor.sys.pq.ultrares.strength"]="0"
            )
            COMMENT_OUT_PROPS=(
                # Optimize Dalvik VM for better app performance (slow app install so remove for now)
                "dalvik.vm.dex2oat-flags" # =--compiler-filter=everything
                "dalvik.vm.image-dex2oat-flags" # =--compiler-filter=everything
                "power.saving.mode"
                "ro.control_privapp_permissions"
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
        local replacement_device="${DEVICE_CODENAME:-rosemary}"
        
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
    
    # Process properties to comment out and collect them
    local COMMENTED_LINES=""
    local commented_count=0
    
    for prop in "${COMMENT_OUT_PROPS[@]}"; do
        # Escape special characters for regex
        local escaped_prop=$(sed 's/[.]/\\./g' <<< "$prop")
        
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
            sed -i "/^[[:space:]]*${escaped_prop}=/d" "$temp_file"
            echo -e "  ${YELLOW}✓ Commented/Moved: $prop${NORMAL}"
            ((commented_count++))
            log_message "INFO" "Commented out: $prop"
        done < <(grep -P "^(#\s*)?${escaped_prop}=" "$temp_file" 2>/dev/null || true)
    done
    
    # Process properties
    local modified_count=0
    local added_count=0
    
    # Add barrier
    echo -e "\n########## Pyro Build Modifications Start ##########\n" >> "$temp_file"
    
    # Add commented out properties section if any exist
    if [[ -n "$COMMENTED_LINES" ]]; then
        echo -e "# Removed Properties:\n" >> "$temp_file"
        echo -e "$COMMENTED_LINES" >> "$temp_file"
    fi
    
    # Initialize categorization arrays
    local MODIFIED_PROPERTIES=()
    local ADDED_PROPERTIES=()
    local UNMODIFIED_PROPERTIES=()
    
    # Process all properties
    for prop_name in "${!PROPERTY_VALUES[@]}"; do
        local new_value="${PROPERTY_VALUES[$prop_name]}"
        
        # Remove existing instances (if not already removed by comment out process)
        sed -i "/^#*[[:space:]]*${prop_name}=/d" "$temp_file"
        
        if [[ -n "${ORIGINAL_VALUES[$prop_name]}" ]]; then
            local original_value="${ORIGINAL_VALUES[$prop_name]}"
            if [[ "$new_value" != "$original_value" ]]; then
                MODIFIED_PROPERTIES+=("$prop_name=$new_value|$original_value")
                ((modified_count++))
            else
                UNMODIFIED_PROPERTIES+=("$prop_name=$new_value")
            fi
        else
            ADDED_PROPERTIES+=("$prop_name=$new_value")
            ((added_count++))
        fi
    done
    
    # Add Modified Properties Section
    if [[ ${#MODIFIED_PROPERTIES[@]} -gt 0 ]]; then
        echo -e "\n# Modified Properties:\n" >> "$temp_file"
        for entry in "${MODIFIED_PROPERTIES[@]}"; do
            IFS='|' read -r prop_entry original_value <<< "$entry"
            prop_name="${prop_entry%%=*}"
            echo "$prop_entry    # Was: ${original_value}" >> "$temp_file"
            echo -e "  ${GREEN}✓ Modified: ${prop_entry} (was: '${original_value}')${NORMAL}"
            log_message "INFO" "Modified: $prop_entry (was: ${original_value})"
        done
    fi
    
    # Add Added Properties Section
    if [[ ${#ADDED_PROPERTIES[@]} -gt 0 ]]; then
        echo -e "\n# Added Properties:\n" >> "$temp_file"
        for prop_entry in "${ADDED_PROPERTIES[@]}"; do
            echo "$prop_entry" >> "$temp_file"
            echo -e "  ${BLUE}✓ Added: $prop_entry${NORMAL}"
            log_message "INFO" "Added: $prop_entry"
        done
    fi
    
    # Add Unmodified Properties Section
    if [[ ${#UNMODIFIED_PROPERTIES[@]} -gt 0 ]]; then
        echo -e "\n# Unmodified Properties (explicitly maintained):\n" >> "$temp_file"
        for prop_entry in "${UNMODIFIED_PROPERTIES[@]}"; do
            echo "$prop_entry" >> "$temp_file"
            echo -e "  ${YELLOW}✓ Maintained: $prop_entry${NORMAL}"
            log_message "INFO" "Maintained: $prop_entry"
        done
    fi
    
    echo -e "########## Pyro Build End ##########" >> "$temp_file"
    
    # Replace original file
    local permissions=$(stat -c "%a" "$build_prop")
    local owner=$(stat -c "%U:%G" "$build_prop")
    
    mv "$temp_file" "$build_prop"
    chmod "$permissions" "$build_prop"
    chown "$owner" "$build_prop"
    
    echo -e "${GREEN}✅ ${prop_type^} properties updated! Modified: $modified_count, Added: $added_count, Commented: $commented_count${NORMAL}"
    echo -e "  ${CYAN}📦 Backup saved: $backup_file${NORMAL}\n"
    log_message "INFO" "Pyro_${prop_type}_prop_builder completed successfully. Modified: $modified_count, Added: $added_count, Commented: $commented_count"
}

run_copier() {
    echo -e "${BOLD}${CYAN}[3/11] Running Pyro Copier...${NORMAL}"
    log_message "INFO" "Starting Pyro_copier"
    
    # Configuration
    declare -A path_map=(
        # EXAMPLES
    #    ["/path/to/source/file1"]="/target/directory1"                        # Regular file copy
    #    ["/path/to/source/folder1"]="/target/directory2:clear"                # Clear target before copying directory
    #    ["/path/to/source/folder2"]="/target/directory3:content"              # Copy folder CONTENTS (not the folder itself)
    #    ["/path/to/source/folder3"]="/target/directory4:clear:content"        # Clear target & copy folder contents
    #    ["/path/to/source/folder4"]="/target/directory5:clear:content:valid"  # Create destination if it doesn't exist

#        ["product/etc/device_features"]="$BASE_DIR/product_a/etc/device_features:clear:content" # Needed based on variant
#        ["product/etc/displayconfig"]="$BASE_DIR/product_a/etc/displayconfig:clear:content"     # Needed based on variant
#        ["product/etc/auto-install.json"]="$BASE_DIR/product_a/etc"    # no auto app installing

        ["tmp/product_a/etc/device_features"]="$BASE_DIR/product_a/etc/device_features:clear:content"
        ["tmp/product_a/etc/displayconfig"]="$BASE_DIR/product_a/etc/displayconfig:clear:content"
        ["tmp/product_a/overlay"]="$BASE_DIR/product_a/overlay:content"
        ["tmp/product_a/priv-app/MiuiCamera"]="$BASE_DIR/product_a/priv-app/MiuiCamera:clear:content:valid"
        ["tmp/product_a/app/MiuiBiometric"]="$BASE_DIR/product_a/app/MiuiBiometric:clear:content:valid"

#
#
#        ["vendor/overlay"]="$BASE_DIR/vendor_a/overlay:content" # Rounded Ui
#        ["vendor/etc"]="$BASE_DIR/vendor_a/etc:content"         # thermals
#
#    #    ["product/priv-app/Viper4AndroidFX"]="$BASE_DIR/product_a/priv-app/Viper4AndroidFX:clear:content:valid" # Viper Soundfx
#    #    ["product/etc/permissions/privapp-permissions-dsps.xml"]="$BASE_DIR/product_a/etc/permissions"          # Viperfx perms
#    #    ["system/etc/audio_effects.conf"]="$BASE_DIR/system_a/system/etc"                                       # Viperfx and Dolby configs
#
#        ["product/Moverlay"]="$BASE_DIR/product_a/overlay:content"  # MIUI / HOS1
#    #    ["product/Hoverlay"]="$BASE_DIR/product_a/overlay:content" # HOS1.1 / HOS2
#
#        ["product/priv-app/MiuiCamera"]="$BASE_DIR/product_a/priv-app/MiuiCamera:clear:content:valid"     # Stock cam Miui/hos1
#    #    ["product/priv-app/MiuiCamerauni"]="$BASE_DIR/product_a/priv-app/MiuiCamera:clear:content"       # Universal cam for hos2
#        ["product/app/MiuiBiometric"]="$BASE_DIR/product_a/app/MiuiBiometric:clear:content:valid"         # face unlock fix
#    #    ["product/app/LatinImeGoogle"]="$BASE_DIR/product_a/app/LatinImeGoogle:clear:content:valid"       # Gboard for CN base
#        ["product/priv-app/MiuiHomeT"]="$BASE_DIR/product_a/priv-app/MiuiHomeT:clear:content:valid"       # Add miui home launcher MIUI only
#
#        # theme stuff
#        ["product/media/theme/default/com.android.systemui"]="$BASE_DIR/product_a/media/theme/default" # Custom status-bar icons
#        ["product/media/theme/default/icons"]="$BASE_DIR/product_a/media/theme/default" # Custom app icons

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
        ["product/priv-app/MiuiHomeT"]="Add CN Miui home launcher if it's a Global A13 Base?"
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
# add to perms
#
#   <privapp-permissions package="com.android.contacts">
#      <permission name="android.permission.CALL_PRIVILEGED" />
#      <permission name="android.permission.READ_PHONE_STATE" />
#      <permission name="android.permission.MODIFY_PHONE_STATE" />
#      <permission name="android.permission.ALLOW_ANY_CODEC_FOR_PLAYBACK" />
#      <permission name="android.permission.REBOOT" />
#      <permission name="android.permission.UPDATE_DEVICE_STATS" />
#      <permission name="android.permission.WRITE_APN_SETTINGS" />
#      <permission name="android.permission.WRITE_SECURE_SETTINGS" />
#      <permission name="android.permission.BIND_DIRECTORY_SEARCH" />
#      <permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" />
#      <permission name="android.permission.INTERACT_ACROSS_USERS" />
#   </privapp-permissions>
#   <privapp-permissions package="com.android.incallui">
#      <permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" />
#      <permission name="android.permission.READ_PHONE_STATE" />
#      <permission name="android.permission.MODIFY_PHONE_STATE" />
#      <permission name="android.permission.CONTROL_INCALL_EXPERIENCE" />
#      <permission name="android.permission.STOP_APP_SWITCHES" />
#      <permission name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS" />
#      <permission name="android.permission.STATUS_BAR" />
#      <permission name="android.permission.CAPTURE_AUDIO_OUTPUT" />
#      <permission name="android.permission.CALL_PRIVILEGED" />
#      <permission name="android.permission.WRITE_MEDIA_STORAGE" />
#      <permission name="android.permission.INTERACT_ACROSS_USERS" />
#      <permission name="android.permission.MANAGE_USERS" />
#      <permission name="android.permission.START_ACTIVITIES_FROM_BACKGROUND" />
#   </privapp-permissions>
#   <privapp-permissions package="com.android.mms">
#      <permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" />
#      <permission name="android.permission.READ_PHONE_STATE" />
#      <permission name="android.permission.CALL_PRIVILEGED" />
#      <permission name="android.permission.GET_ACCOUNTS_PRIVILEGED" />
#      <permission name="android.permission.WRITE_SECURE_SETTINGS" />
#      <permission name="android.permission.SEND_SMS_NO_CONFIRMATION" />
#      <permission name="android.permission.SEND_RESPOND_VIA_MESSAGE" />
#      <permission name="android.permission.UPDATE_APP_OPS_STATS" />
#      <permission name="android.permission.MODIFY_PHONE_STATE" />
#      <permission name="android.permission.WRITE_MEDIA_STORAGE" />
#      <permission name="android.permission.MANAGE_USERS" />
#      <permission name="android.permission.WRITE_APN_SETTINGS" />
#      <permission name="android.permission.INTERACT_ACROSS_USERS" />
#      <permission name="android.permission.SCHEDULE_EXACT_ALARM" />
#   </privapp-permissions>
        
        local tmpfile=$(mktemp)
        cat <<'EOF' > "$tmpfile"
   <privapp-permissions package="com.miui.home">
      <permission name="android.permission.CHANGE_COMPONENT_ENABLED_STATE" />
      <permission name="android.permission.SET_WALLPAPER_COMPONENT" />
      <permission name="android.permission.BIND_WALLPAPER" />
      <permission name="android.permission.BROADCAST_CLOSE_SYSTEM_DIALOGS" />
      <permission name="android.permission.BIND_APPWIDGET" />
      <permission name="android.permission.CHANGE_CONFIGURATION" />
      <permission name="android.permission.DELETE_PACKAGES" />
      <permission name="android.permission.DUMP" />
      <permission name="android.permission.STATUS_BAR" />
      <permission name="android.permission.UPDATE_DEVICE_STATS" />
      <permission name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS" />
      <permission name="android.permission.UPDATE_APP_OPS_STATS" />
      <permission name="android.permission.MEDIA_CONTENT_CONTROL" />
      <permission name="android.permission.SET_PROCESS_LIMIT" />
      <permission name="android.permission.PACKAGE_USAGE_STATS" />
      <permission name="android.permission.WRITE_SECURE_SETTINGS" />
      <permission name="android.permission.INTERACT_ACROSS_USERS" />
      <permission name="android.permission.MANAGE_USERS" />
      <permission name="android.permission.FORCE_STOP_PACKAGES" />
      <permission name="android.permission.START_TASKS_FROM_RECENTS" />
      <permission name="android.permission.CONTROL_REMOTE_APP_TRANSITION_ANIMATIONS" />
      <permission name="android.permission.REAL_GET_TASKS" />
      <permission name="android.permission.ALLOW_SLIPPERY_TOUCHES" />
      <permission name="android.permission.READ_PHONE_STATE" />
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
    echo -e "${BOLD}${CYAN}[4/11] Running Pyro MI_EXT Mover...${NORMAL}"
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

run_file_appender() {
    echo -e "${BOLD}${CYAN}[8/11] Running Pyro File Appender...${NORMAL}"
    log_message "INFO" "Starting Pyro_file_appender"
    
    # Configuration - Map of files to their content to append
    declare -A file_append_map=(
        ["$BASE_DIR/system_a/system/etc/init/hw/init.rc"]="
# Pyro Modifications
on init && property:ro.secureboot.devicelock=1
    setprop ro.secureboot.lockstate locked

on property:sys.boot_completed=1
    start animationfix

service animationfix /system/bin/sh -c 'settings put system deviceLevelList v:1,c:3,g:3'
    seclabel u:r:shell:s0
    user root
    oneshot
    disabled"

        ["$BASE_DIR/system_ext_a/etc/cust_prop_white_keys_list"]="
# Pyro Modifications
ro.boot.verifiedbootstate"
        
        # Add more file modifications here as needed
        # ["$BASE_DIR/path/to/another/file"]="content to append"
    )
    
    local appended_count=0
    local errors=0
    local skipped_count=0
    
    for target_file in "${!file_append_map[@]}"; do
        local content_to_append="${file_append_map[$target_file]}"
        
        # Try fallback path if primary doesn't exist
        local working_file="$target_file"
        if [[ ! -f "$target_file" ]]; then
            local fallback_file="${target_file/_a/}"
            if [[ -f "$fallback_file" ]]; then
                working_file="$fallback_file"
                echo -e "  ${YELLOW}ℹ️  Using fallback: $working_file${NORMAL}"
            else
                echo -e "  ${RED}❌ File not found: $target_file${NORMAL}"
                ((errors++))
                log_message "ERROR" "File not found: $target_file"
                continue
            fi
        fi
        
        # Check if content is already present to avoid duplicates
        if grep -qF "Pyro Security Modifications\|Pyro Vendor Modifications\|Pyro Product Modifications" "$working_file" 2>/dev/null; then
            echo -e "  ${YELLOW}⚠️  Pyro modifications already present in: $(basename "$working_file")${NORMAL}"
            ((skipped_count++))
            log_message "INFO" "Skipped (already modified): $working_file"
            continue
        fi
        
        # Create backup
        local backup_file="${working_file}.bak"
        if ! cp "$working_file" "$backup_file"; then
            echo -e "  ${RED}❌ Failed to create backup for: $working_file${NORMAL}"
            ((errors++))
            log_message "ERROR" "Backup failed for: $working_file"
            continue
        fi
        
        # Append content to file
        echo -e "  ${GREEN}✓ Appending to: $(basename "$working_file")${NORMAL}"
        if echo -e "$content_to_append" >> "$working_file"; then
            ((appended_count++))
            log_message "INFO" "Content appended to: $working_file"
            
            # Preserve original permissions
            local permissions=$(stat -c "%a" "$backup_file")
            local owner=$(stat -c "%U:%G" "$backup_file")
            chmod "$permissions" "$working_file"
            chown "$owner" "$working_file"
        else
            echo -e "    ${RED}❌ Failed to append content${NORMAL}"
            ((errors++))
            log_message "ERROR" "Failed to append content to: $working_file"
            # Restore from backup
            mv "$backup_file" "$working_file"
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}✅ File appender completed! Appended: $appended_count, Skipped: $skipped_count${NORMAL}\n"
    else
        echo -e "${YELLOW}⚠️  File appender completed with $errors error(s). Appended: $appended_count, Skipped: $skipped_count${NORMAL}\n"
    fi
    
    log_message "INFO" "Pyro_file_appender completed. Appended: $appended_count, Skipped: $skipped_count, Errors: $errors"
}

run_file_remover() {
    echo -e "${BOLD}${CYAN}[9/11] Running Pyro File Remover...${NORMAL}"
    log_message "INFO" "Starting Pyro_file_remover"
    
    # Configuration - Map of directories to files/folders to remove from them
    declare -A removal_map=(
        # Format: ["directory_path"]="file1 file2 folder1 folder2"
        # You can also target specific subdirectories
        ["$BASE_DIR/system_a/system/bin"]="hdrfix.rc logd.rc logd hdrfix"
        ["$BASE_DIR/system_a/system/etc/init"]="logcattt.rc hdrfix.rc logd.rc"
        ["$BASE_DIR/system_a/system/priv-app"]="dpmserviceapp"
        ["$BASE_DIR/system_ext_a/priv-app"]="dpmserviceapp"
        ["$BASE_DIR/system_ext_a/app"]="dpmserviceapp"
        ["$BASE_DIR/product_a/media/theme/"]="cust_config"
        ["$BASE_DIR/product_a/pangu/system/etc/permissions"]="facebook-hiddenapi-package-whitelist.xml facebook-miui.xml"
    )
    
    local removed_count=0
    local errors=0
    local not_found_count=0
    
    for target_dir in "${!removal_map[@]}"; do
        local items_to_remove="${removal_map[$target_dir]}"
        
        # Try fallback path if primary doesn't exist
        local working_dir="$target_dir"
        if [[ ! -d "$target_dir" ]]; then
            local fallback_dir="${target_dir/_a/}"
            if [[ -d "$fallback_dir" ]]; then
                working_dir="$fallback_dir"
                echo -e "  ${YELLOW}ℹ️  Using fallback directory: $working_dir${NORMAL}"
            else
                echo -e "  ${YELLOW}⚠️  Directory not found: $target_dir${NORMAL}"
                ((errors++))
                log_message "WARNING" "Directory not found: $target_dir"
                continue
            fi
        fi
        
        echo -e "  ${CYAN}Processing directory: $(basename "$working_dir")${NORMAL}"
        
        # Process each item to remove
        for item in $items_to_remove; do
            local full_path="$working_dir/$item"
            
            if [[ -e "$full_path" ]]; then
                echo -e "    ${RED}🗑️  Removing: $item${NORMAL}"
                if rm -rf "$full_path"; then
                    ((removed_count++))
                    log_message "INFO" "Removed: $full_path"
                else
                    echo -e "      ${RED}❌ Failed to remove: $item${NORMAL}"
                    ((errors++))
                    log_message "ERROR" "Failed to remove: $full_path"
                fi
            else
                echo -e "    ${YELLOW}ℹ️  Not found (skipping): $item${NORMAL}"
                ((not_found_count++))
                log_message "INFO" "Not found (skipped): $full_path"
            fi
        done
    done
    
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}✅ File remover completed! Removed: $removed_count, Not found: $not_found_count${NORMAL}\n"
    else
        echo -e "${YELLOW}⚠️  File remover completed with $errors error(s). Removed: $removed_count, Not found: $not_found_count${NORMAL}\n"
    fi
    
    log_message "INFO" "Pyro_file_remover completed. Removed: $removed_count, Not found: $not_found_count, Errors: $errors"
}

run_super_packer() {
    # Small patch
    mv UKL/UnpackerSystem/product_a/pangu/system/* UKL/UnpackerSystem/system_a/system/ || true
    rm -rf UKL/UnpackerSystem/product_a/pangu || true
    
    chmod +x Water.sh
    chmod +x Burn.sh
    ./Water.sh ./UKL/run.sh
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
    
    for i in {1..11}; do
        IFS='|' read -r script_name description <<< "${SCRIPTS[$i]}"
        echo -e "  ${YELLOW}[$i]${NORMAL} ${BOLD}$script_name${NORMAL}"
    done
    
    echo
    while true; do
        read -p "Enter your selection: " selection
        
        # Validate and parse selection
        if [[ "$selection" =~ ^[1-9](,[1-9])*$|^(10|11)(,[1-9])*$|^[1-9](,(10|11))*$|^[1-9](,[1-9]|,(10|11))*$ ]]; then
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
            echo -e "${RED}Invalid format. Use comma-separated numbers (1-11), e.g., 1,3,5${NORMAL}"
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
            8) run_file_appender ;;
            9) run_file_remover ;;
            10) run_prop_builder "vendor" "$BASE_DIR/vendor_a/build.prop" "$current_step" "$total_scripts" ;;
            11) run_super_packer ;;
        esac
    done
    
    echo -e "${BOLD}${GREEN}🎉 PyroOS build sequence completed successfully!${NORMAL}"
    echo -e "${CYAN}📋 Check the log file for detailed information: $LOG_FILE${NORMAL}\n"
    log_message "INFO" "PyroOS build sequence completed successfully"
}

main() {
    local codename="$1"
    
    print_header
    validate_environment
    
    if [[ -n "$codename" ]]; then
        print_status "Found $codename >:)"
        export DEVICE_CODENAME="$codename"
        print_status "'$codename' applied successfully!"
    else
        print_warning "No codename found, using default: rosemary >_<"
        export DEVICE_CODENAME="rosemary"
    fi
    
    
    while true; do
        print_menu
        echo
        
        local choice
        while true; do
            read -p "Enter your choice [A/S/Q]: " choice
            case "${choice,,}" in
                a|all)
                    echo -e "\n${BOLD}${GREEN}Running ALL scripts in sequence...${NORMAL}\n"
                    run_selected_scripts {1..11}
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
    main "$1"
fi