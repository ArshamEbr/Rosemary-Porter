#!/usr/bin/env bash

set -e  # Exit on any error

FORCE_EXTRACT_ZIP=false
FORCE_EXTRACT_PAYLOAD=false
PYRO_ONLY=false
for arg in "$@"; do
    case $arg in
        --force-extract)
            FORCE_EXTRACT_ZIP=true
            FORCE_EXTRACT_PAYLOAD=true
            shift
            ;;
        --force-extract-zip)
            FORCE_EXTRACT_ZIP=true
            shift
            ;;
        --force-extract-payload)
            FORCE_EXTRACT_PAYLOAD=true
            shift
            ;;
        --pyro-only)
            PYRO_ONLY=true
            shift
            ;;
        -h|--help)
            echo "DO NOT RUN! any of these, only used for debuging"
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --force-extract         Force re-extraction of both zip and payload"
            echo "  --force-extract-zip     Force re-extraction of zip files only"
            echo "  --force-extract-payload Force re-extraction of payload files only"
            echo "  --pyro-only             Run only Pyro.sh script (skip ROM extraction)"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [[ -n "$SUDO_USER" ]]; then
    USERNAME="$SUDO_USER"
else
    USERNAME=$(whoami)
fi
BASE_PATH="/home/$USERNAME/Rosemary-Porter"

echo -e "${BLUE}Pyro Porter Automation${NC}"
echo -e "${BLUE}Nice Username: $USERNAME${NC}"
echo -e "${BLUE}Base Path: $BASE_PATH${NC}"
echo ""

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_payload_extracted() {
    local rom_type="$1"
    local extracted_dir=""
    
    if [[ "$rom_type" == "stock" ]]; then
        extracted_dir=$(find stock/ -maxdepth 1 -type d -not -name "stock" | head -1)
    else
        extracted_dir=$(find port/ -maxdepth 1 -type d -not -name "port" | head -1)
    fi
    
    if [[ -n "$extracted_dir" ]] && [[ -f "$extracted_dir/payload.bin" ]]; then
        return 0
    else
        return 1
    fi
}

check_payload_ukl_extracted() {
    local rom_type="$1"
    
    # Check if UKL/UnpackerPayload has any extracted files from this ROM
    if [[ -d "UKL/UnpackerPayload" ]]; then
        local file_count=$(find UKL/UnpackerPayload -name "*.img" | wc -l)
        if [[ $file_count -gt 0 ]]; then
            return 0  # UKL extraction already done
        fi
    fi
    
    return 1  # UKL extraction not done
}

debug_available_images() {
    print_status "Debugging: Listing available image files..."
    
    if [[ -d "UKL/UnpackerSuper" ]]; then
        print_status "Files in UKL/UnpackerSuper:"
        ls -la UKL/UnpackerSuper/ || true
    else
        print_warning "UKL/UnpackerSuper directory doesn't exist!"
    fi
    
    if [[ -d "UKL/UnpackerPayload" ]]; then
        print_status "Files in UKL/UnpackerPayload:"
        ls -la UKL/UnpackerPayload/ || true
    else
        print_warning "UKL/UnpackerPayload directory doesn't exist!"
    fi
}

run_pyro_only() {
    print_status "Running Pyro.sh only mode..."
    
    print_status "Looking for device codename in existing files..."
    DEVICE_CODENAME=""
    
    if [[ -f "UKL/UnpackerSystem/mi_ext_a/etc/build.prop" ]]; then
        DEVICE_CODENAME=$(grep "ro.product.mod_device" UKL/UnpackerSystem/mi_ext_a/etc/build.prop 2>/dev/null | cut -d'=' -f2 || true)
        if [[ -n "$DEVICE_CODENAME" ]]; then
            print_status "Found device codename in mi_ext_a: $DEVICE_CODENAME"
        fi
    fi
    
    if [[ -z "$DEVICE_CODENAME" ]] && [[ -f "UKL/UnpackerSystem/product_a/etc/build.prop" ]]; then
        DEVICE_CODENAME=$(grep "ro.product.product.name" UKL/UnpackerSystem/product_a/etc/build.prop 2>/dev/null | cut -d'=' -f2 || true)
        if [[ -n "$DEVICE_CODENAME" ]]; then
            print_status "Found device codename in product_a: $DEVICE_CODENAME"
        fi
    fi
    
    if [[ -z "$DEVICE_CODENAME" ]]; then
        print_warning "Device codename not found in extracted files."
        read -p "Please enter device codename manually: " DEVICE_CODENAME
        if [[ -z "$DEVICE_CODENAME" ]]; then
            print_error "No device codename provided!"
            exit 1
        fi
    fi
    
    print_status "Using device codename: $DEVICE_CODENAME"
    
    print_status "Running Pyro.sh script with device codename: $DEVICE_CODENAME"
    if [[ -f "Pyro.sh" ]]; then
        chmod +x Pyro.sh
        
        expect -c "
            set timeout 300
            log_user 1
        
            spawn ./Pyro.sh {$DEVICE_CODENAME}
        
            expect {
                timeout { 
                    puts \"Timeout running Pyro.sh\"
                    exit 1 
                }
                -re {Enter your choice .*A/S/Q.*:} {
                    puts \"Starting the Pyro modifications soon...\"
                    after 5000
                    send -- \"A\r\"
                    flush stdout
                    exp_continue
                }
                eof {
                    puts \"Pyro.sh completed successfully\"
                    exit 0
                }
            }
        "
        
        if [[ $? -eq 0 ]]; then
            print_status "Pyro.sh script completed."
        else
            print_error "Pyro.sh script failed!"
            exit 1
        fi
    else
        print_error "Pyro.sh script not found!"
        exit 1
    fi
    
    print_status "Pyro-only mode completed successfully!"
    exit 0
}

check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v expect &> /dev/null; then
        print_error "expect is not installed. Please install it: sudo apt-get install expect"
        exit 1
    fi
    
    if ! command -v unzip &> /dev/null; then
        print_error "unzip is not installed. Please install it: sudo apt-get install unzip"
        exit 1
    fi
    
    print_status "All dependencies are available."
}

extract_payload() {
    local payload_path="$1"
    local rom_type="$2"
    
    print_status "Extracting $rom_type payload.bin using UKL..."
    
    expect -c "
        set timeout 300
        log_user 1
        
        spawn ./UKL/run.sh
        
        # Wait for main menu and send 11 with longer delay
        expect {
            timeout { 
                puts \"Timeout waiting for main menu\"
                exit 1 
            }
            \"#? \" { 
                send -- \"11\"
                send -- \"\\r\"
            }
        }
        
        expect {
            timeout { 
                puts \"Timeout waiting for other tools menu\"
                exit 1 
            }
            \"#? \" { 
                send -- \"6\\r\"
            }
        }
        
        expect {
            timeout { 
                puts \"Timeout waiting for cd prompt\"
                exit 1 
            }
            -re \".*cd.*\" { 
                send -- \"cd $payload_path\\r\"
            }
        }
        
        expect {
            timeout { 
                puts \"Timeout waiting for file selection\"
                exit 1 
            }
            \"#? \" { 
                send -- \"1\\r\"
            }
        }
        
        expect {
            timeout { 
                puts \"Timeout waiting for completion\"
                exit 1 
            }
            -re \".*Main MENU.*\" { 
                send -- \"14\\r\"
            }
        }
        
        expect eof
    "
    
    if [[ $? -ne 0 ]]; then
        print_error "UKL extraction failed for $rom_type"
        exit 1
    fi
    
    print_status "$rom_type payload.bin extraction completed."
}

extract_images() {
    local images=("$@")
    
    for image in "${images[@]}"; do
        print_status "Extracting $image using UKL..."
        
        # Check if image file exists first
        if [[ ! -f "UKL/UnpackerSuper/$image" ]]; then
            print_warning "Image file UKL/UnpackerSuper/$image not found, skipping extraction"
            continue
        fi
        
        expect -c "
            set timeout 300
            log_user 1
            
            spawn ./UKL/run.sh
            
            expect {
                timeout { 
                    puts \"Timeout waiting for main menu\"
                    exit 1 
                }
                \"#? \" { 
                    send -- \"3\\r\"
                }
            }
            
            expect {
                timeout { 
                    puts \"Timeout waiting for unpack menu\"
                    exit 1 
                }
                \"#? \" { 
                    send -- \"2\\r\"
                }
            }
            
            expect {
                timeout { 
                    puts \"Timeout waiting for file selection prompt\"
                    exit 1 
                }
                \"#? \" {
                    set buffer \$expect_out(buffer)
                    set found_number 0
                    
                    # Print the buffer to see what's available
                    puts \"Available files in UKL menu:\"
                    puts \$buffer
                    
                    if {[regexp {1\)\s*$image\s} \$buffer]} {
                        set found_number 1
                    } elseif {[regexp {2\)\s*$image\s} \$buffer]} {
                        set found_number 2
                    } elseif {[regexp {3\)\s*$image\s} \$buffer]} {
                        set found_number 3
                    } elseif {[regexp {4\)\s*$image\s} \$buffer]} {
                        set found_number 4
                    } elseif {[regexp {5\)\s*$image\s} \$buffer]} {
                        set found_number 5
                    } elseif {[regexp {6\)\s*$image\s} \$buffer]} {
                        set found_number 6
                    } elseif {[regexp {7\)\s*$image\s} \$buffer]} {
                        set found_number 7
                    } elseif {[regexp {8\)\s*$image\s} \$buffer]} {
                        set found_number 8
                    }
                    
                    if {\$found_number > 0} {
                        puts \"Found $image at position \$found_number\"
                        send -- \"\$found_number\\r\"
                    } else {
                        puts \"Could not find $image in the current list\"
                        puts \"Exiting UKL menu\"
                        send -- \"8\\r\"
                        expect \"#? \"
                        send -- \"14\\r\"
                        exit 1
                    }
                }
            }
            
            # Wait for extraction to complete and return to main menu
            expect {
                timeout { 
                    puts \"Timeout waiting for extraction completion\"
                    exit 1 
                }
                -re \".*Main MENU.*\" { 
                    send -- \"14\\r\"
                }
            }
            
            expect eof
        "
        
        local extract_result=$?
        if [[ $extract_result -ne 0 ]]; then
            print_warning "UKL image extraction failed for $image, continuing with next image"
            continue
        fi
        
        print_status "$image extraction completed."
    done
}

# Function to find device codename
find_device_codename() {
    local codename=""
    
    # First try mi_ext_a/etc/build.prop
    if [[ -f "UKL/UnpackerSystem/mi_ext_a/etc/build.prop" ]]; then
        codename=$(grep "ro.product.mod_device" UKL/UnpackerSystem/mi_ext_a/etc/build.prop 2>/dev/null | cut -d'=' -f2 || true)
        if [[ -n "$codename" ]]; then
            echo "$codename"
            return 0
        fi
    fi
    
    # Try product_a/etc/build.prop
    if [[ -f "UKL/UnpackerSystem/product_a/etc/build.prop" ]]; then
        codename=$(grep "ro.product.product.name" UKL/UnpackerSystem/product_a/etc/build.prop 2>/dev/null | cut -d'=' -f2 || true)
        if [[ -n "$codename" ]]; then
            echo "$codename"
            return 0
        fi
    fi
    
    return 1
}

# Function to copy files with directory structure
copy_with_structure() {
    local src="$1"
    local dst="$2"
    
    if [[ -e "$src" ]]; then
        print_status "Copying $src to $dst"
        mkdir -p "$(dirname "$dst")"
        cp -r "$src" "$dst"
    else
        print_warning "Source not found: $src (skipping)"
    fi
}

# Main script execution
main() {
    print_status "Starting ROM porting automation..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (with sudo)"
        print_status "Please run: sudo ./GO.sh"
        exit 1
    fi
    
    # Check if running in Pyro-only mode
    if [[ "$PYRO_ONLY" == true ]]; then
        run_pyro_only
    fi
    
    # Check dependencies
    check_dependencies
    
    # Change to base directory
    cd "$BASE_PATH" || exit 1
    
    # Create necessary directories
    mkdir -p tmp/product_a/{priv-app,app,etc,overlay}
    mkdir -p output/fw
    
    # ============= STOCK ROM PROCESSING =============
    print_status "Processing STOCK ROM..."
    
    # Extract stock ROM zip
    print_status "Extracting stock ROM zip..."
    if check_payload_extracted "stock" && [[ "$FORCE_EXTRACT_ZIP" == false ]]; then
        print_status "Stock ROM already extracted, skipping zip extraction. Use --force-extract-zip to re-extract."
    else
        if [[ "$FORCE_EXTRACT_ZIP" == true ]]; then
            print_status "Force zip extraction enabled, re-extracting stock ROM..."
            # Clean up existing extraction
            find stock/ -maxdepth 1 -type d -not -name "stock" -exec rm -rf {} + 2>/dev/null || true
        fi
        
        stock_zip=$(find stock/ -name "*.zip" -type f | head -1)
        if [[ -n "$stock_zip" ]]; then
            unzip -o "$stock_zip" -d stock/
            print_status "Stock ROM zip extracted from $stock_zip."
        else
            print_error "No zip file found for stock ROM!"
            print_status "Please ensure you have a zip file inside the stock/ directory"
            exit 1
        fi
    fi
    
    stock_payload_dir=$(find stock/ -name "payload.bin" -type f -exec dirname {} \; | head -1)
    if [[ -z "$stock_payload_dir" ]]; then
        print_error "Could not find payload.bin in stock directory!"
        exit 1
    fi
    
    export PAYLOAD_PATH="$BASE_PATH/$stock_payload_dir"
    print_status "Found stock payload at: $PAYLOAD_PATH"
    
    if check_payload_ukl_extracted "stock" && [[ "$FORCE_EXTRACT_PAYLOAD" == false ]]; then
        print_status "Stock payload already extracted by UKL, skipping payload extraction. Use --force-extract-payload to re-extract."
    else
        if [[ "$FORCE_EXTRACT_PAYLOAD" == true ]]; then
            print_status "Force payload extraction enabled, cleaning UKL directories..."
            rm -rf UKL/UnpackerPayload/* 2>/dev/null || true
        fi
        extract_payload "$BASE_PATH/$stock_payload_dir" "stock"
    fi
    
    print_status "Moving stock images to UnpackerSuper..."
    mv UKL/UnpackerPayload/mi_ext.img UKL/UnpackerSuper/mi_ext_a.img
    mv UKL/UnpackerPayload/system.img UKL/UnpackerSuper/system_a.img
    mv UKL/UnpackerPayload/system_ext.img UKL/UnpackerSuper/system_ext_a.img
    mv UKL/UnpackerPayload/product.img UKL/UnpackerSuper/product_a.img
    mv UKL/UnpackerPayload/vendor.img UKL/UnpackerSuper/vendor_a.img
    
    # Move remaining files to output/fw
    print_status "Moving remaining stock files to output/fw..."
    mv UKL/UnpackerPayload/* output/fw/ 2>/dev/null || true
    chmod u+w output/fw/* 2>/dev/null || true
    rm -f output/fw/vbmeta.img output/fw/vbmeta_system.img output/fw/vbmeta_vendor.img
    
    # Remove stock extracted folder (keep zip)
    print_status "Cleaning up stock extracted files..."
    find stock/ -type d -not -name "stock" -not -name "*.zip" -exec rm -rf {} + 2>/dev/null || true
    find stock/ -type f -not -name "*.zip" -exec rm -f {} + 2>/dev/null || true
    
    # Debug what images are available
    debug_available_images
    
    print_status "Extracting stock images..."
    
    print_status "Extracting mi_ext_a.img..."
    extract_images "mi_ext_a.img"
    
    print_status "Extracting product_a.img..."
    extract_images "product_a.img"
    
    print_status "Extracting vendor_a.img..."
    extract_images "vendor_a.img"
    
    print_status "Looking for device codename..."
    DEVICE_CODENAME=$(find_device_codename)
    if [[ -n "$DEVICE_CODENAME" ]]; then
        print_status "Found device codename: $DEVICE_CODENAME"
    else
        print_error "Could not find device codename!"
        exit 1
    fi
    
    print_status "Copying required files from stock product_a..."
    
    copy_with_structure "UKL/UnpackerSystem/product_a/priv-app/MiuiCamera" "tmp/product_a/priv-app/MiuiCamera"
    copy_with_structure "UKL/UnpackerSystem/product_a/app/MiuiBiometric" "tmp/product_a/app/MiuiBiometric"
    copy_with_structure "UKL/UnpackerSystem/product_a/etc/device_features" "tmp/product_a/etc/device_features"
    copy_with_structure "UKL/UnpackerSystem/product_a/etc/displayconfig" "tmp/product_a/etc/displayconfig"
    
    copy_with_structure "UKL/UnpackerSystem/product_a/overlay/AospFrameworkResOverlay.apk" "tmp/product_a/overlay/AospFrameworkResOverlay.apk"
    copy_with_structure "UKL/UnpackerSystem/product_a/overlay/DevicesAndroidOverlay.apk" "tmp/product_a/overlay/DevicesAndroidOverlay.apk"
    copy_with_structure "UKL/UnpackerSystem/product_a/overlay/DevicesOverlay.apk" "tmp/product_a/overlay/DevicesOverlay.apk"
    copy_with_structure "UKL/UnpackerSystem/product_a/overlay/MiuiBiometricResOverlay.apk" "tmp/product_a/overlay/MiuiBiometricResOverlay.apk"
    copy_with_structure "UKL/UnpackerSystem/product_a/overlay/MiuiFrameworkResOverlay.apk" "tmp/product_a/overlay/MiuiFrameworkResOverlay.apk"
    
    print_status "Cleaning up extracted stock images..."
    rm -f UKL/UnpackerSuper/product_a.img UKL/UnpackerSuper/mi_ext_a.img UKL/UnpackerSuper/system_a.img UKL/UnpackerSuper/system_ext_a.img UKL/UnpackerSuper/vendor_a.img
    
    print_status "Removing mi_ext folder..."
    rm -rf UKL/UnpackerSystem/mi_ext_a UKL/UnpackerSystem/config/mi_ext_a UKL/UnpackerSystem/config/product_a UKL/UnpackerSystem/config/system_a UKL/UnpackerSystem/config/system_ext_a
    
    print_status "Cleaning up stock system folders..."
    rm -rf UKL/UnpackerSystem/product_a UKL/UnpackerSystem/system_a UKL/UnpackerSystem/system_ext_a
    
    # ============= PORT ROM PROCESSING =============
    print_status "Processing PORT ROM..."
    
    print_status "Extracting port ROM zip..."
    if check_payload_extracted "port" && [[ "$FORCE_EXTRACT_ZIP" == false ]]; then
        print_status "Port ROM already extracted, skipping zip extraction. Use --force-extract-zip to re-extract."
    else
        if [[ "$FORCE_EXTRACT_ZIP" == true ]]; then
            print_status "Force zip extraction enabled, re-extracting port ROM..."
            # Clean up existing extraction
            find port/ -maxdepth 1 -type d -not -name "port" -exec rm -rf {} + 2>/dev/null || true
        fi
        
        port_zip=$(find port/ -name "*.zip" -type f | head -1)
        if [[ -n "$port_zip" ]]; then
            unzip -o "$port_zip" -d port/
            print_status "Port ROM zip extracted from $port_zip."
        else
            print_error "No zip file found for port ROM!"
            print_status "Please ensure you have a zip file inside the port/ directory"
            exit 1
        fi
    fi
    
    port_payload_dir=$(find port/ -name "payload.bin" -type f -exec dirname {} \; | head -1)
    if [[ -z "$port_payload_dir" ]]; then
        print_error "Could not find payload.bin in port directory!"
        exit 1
    fi
    
    export PAYLOAD_PATH="$BASE_PATH/$port_payload_dir"
    print_status "Found port payload at: $PAYLOAD_PATH"
    
    if check_payload_ukl_extracted "port" && [[ "$FORCE_EXTRACT_PAYLOAD" == false ]]; then
        print_status "Port payload already extracted by UKL, skipping payload extraction. Use --force-extract-payload to re-extract."
    else
        if [[ "$FORCE_EXTRACT_PAYLOAD" == true ]]; then
            print_status "Force payload extraction enabled, cleaning UKL directories..."
            rm -rf UKL/UnpackerPayload/* 2>/dev/null || true
        fi
        extract_payload "$BASE_PATH/$port_payload_dir" "port"
    fi
    
    # Move port images to UnpackerSuper with _a suffix
    print_status "Moving port images to UnpackerSuper..."
    mv UKL/UnpackerPayload/mi_ext.img UKL/UnpackerSuper/mi_ext_a.img
    mv UKL/UnpackerPayload/system.img UKL/UnpackerSuper/system_a.img
    mv UKL/UnpackerPayload/system_ext.img UKL/UnpackerSuper/system_ext_a.img
    mv UKL/UnpackerPayload/product.img UKL/UnpackerSuper/product_a.img
    
    # Remove remaining files in UnpackerPayload
    print_status "Cleaning up port UnpackerPayload..."
    rm -rf UKL/UnpackerPayload/*
    
    # Remove port extracted folder (keep zip)
    print_status "Cleaning up port extracted files..."
    find port/ -type d -not -name "port" -not -name "*.zip" -exec rm -rf {} + 2>/dev/null || true
    find port/ -type f -not -name "*.zip" -exec rm -f {} + 2>/dev/null || true
    
    # Debug what images are available
    debug_available_images
    
    # Extract port images one by one for better error handling
    print_status "Extracting port images..."
    
    # Extract each image individually
    extract_images "mi_ext_a.img"
    extract_images "product_a.img"
    extract_images "system_a.img"
    extract_images "system_ext_a.img"
    
    # Run Pyro.sh script
    print_status "Running Pyro.sh script with device codename: $DEVICE_CODENAME"
    if [[ -f "Pyro.sh" ]]; then
        chmod +x Pyro.sh
        
        expect -c "
            set timeout 300
            log_user 1
        
            spawn ./Pyro.sh {$DEVICE_CODENAME}
        
            expect {
                timeout { 
                    puts \"Timeout running Pyro.sh\"
                    exit 1 
                }
                -re {Enter your choice .*A/S/Q.*:} {
                    puts \"Starting the Pyro modifications soon...\"
                    after 5000
                    send -- \"A\r\"
                    flush stdout
                    exp_continue
                }
                eof {
                    puts \"Pyro.sh completed successfully\"
                    exit 0
                }
            }
        "
        
        if [[ $? -eq 0 ]]; then
            print_status "Pyro.sh script completed."
        else
            print_error "Pyro.sh script failed!"
            exit 1
        fi
    else
        print_warning "Pyro.sh script not found!"
    fi
    
    print_status "ROM porting automation completed successfully!"
    print_status "Device codename used: $DEVICE_CODENAME"
    echo ""
    print_status "Summary of operations:"
    echo "  - Extracted and processed stock ROM"
    echo "  - Extracted and processed port ROM"
    echo "  - Copied required stock files to port to prevent bugs"
    echo "  - Moved stock firmware files to output/fw/ for flashing later"
    echo "  - Extracted all necessary image files"
    echo "  - Ran Pyro for device $DEVICE_CODENAME"
}

main "$@"