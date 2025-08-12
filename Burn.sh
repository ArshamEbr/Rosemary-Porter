#!/usr/bin/env bash

# =============================================
# PHASE 1: Move/Prepare Partition Images
# =============================================
echo "🚀 Starting Phase 1: Preparing partition images..."

SOURCE_DIR="UKL/UnpackerSystem"
TARGET_DIR="UKL/UnpackerSuper"

# File pairs (source:target)
FILES=(
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

# Check if source/target directories exist
validate_paths() {
    [[ -d "$SOURCE_DIR" ]] || { echo "❌ Missing source directory: $SOURCE_DIR"; exit 1; }
    [[ -d "$TARGET_DIR" ]] || { echo "❌ Missing target directory: $TARGET_DIR"; exit 1; }
}

# Check available space
check_space() {
    local source_size=$(du -bs "$SOURCE_DIR" | cut -f1)
    local avail_space=$(df -B1 "$TARGET_DIR" | awk 'NR==2 {print $4}')
    (( source_size > avail_space )) && {
        echo "❌ Not enough space in $TARGET_DIR (Needed: $((source_size/1024/1024))MB)";
        exit 1;
    }
}

# Execute Phase 1
validate_paths
check_space

for pair in "${FILES[@]}"; do
    IFS=':' read -r src tgt <<< "$pair"
    src_path="$SOURCE_DIR/$src"
    tgt_path="$TARGET_DIR/$tgt"
    
    if [[ ! -f "$src_path" ]]; then
        echo "⚠️ Skipping missing: $src_path"
        continue
    fi
    
    # Remove old file if it exists (fixed logic)
    if [[ -f "$tgt_path" ]]; then
        if ! rm -f "$tgt_path"; then
            echo "❌ Failed to remove old file: $tgt_path"
            exit 1
        fi
    fi
    
    if mv -n "$src_path" "$tgt_path"; then
        echo "✓ Moved: $src → $tgt"
    else
        echo "❌ Failed to move: $src → $tgt"
        exit 1
    fi
done

echo -e "\n✅ Phase 1 Complete: All partition images prepared.\n"

# =============================================
# PHASE 2: Build Sparse Super Image
# =============================================
echo "🚀 Starting Phase 2: Building sparse super image..."

METADATA_SIZE=65536
SUPER_NAME="super"
METADATA_SLOTS=3
DEVICE_SIZE=9126805504
OUTPUT_IMAGE="output/super.img"

GROUP_A_SIZE=9124708352
GROUP_B_SIZE=9124708352

MI_EXT_A_IMG="$TARGET_DIR/mi_ext_a.img"
PRODUCT_A_IMG="$TARGET_DIR/product_a.img"
SYSTEM_A_IMG="$TARGET_DIR/system_a.img"
SYSTEM_EXT_A_IMG="$TARGET_DIR/system_ext_a.img"
VENDOR_A_IMG="$TARGET_DIR/vendor_a.img"

# Verify critical images exist before lpmake
REQUIRED_IMAGES=("$MI_EXT_A_IMG" "$PRODUCT_A_IMG" "$SYSTEM_A_IMG" "$SYSTEM_EXT_A_IMG" "$VENDOR_A_IMG")
for img in "${REQUIRED_IMAGES[@]}"; do
    [[ ! -f "$img" ]] && {
        echo "❌ Missing required image: $img";
        exit 1;
    }
done

# Get sizes for each image
MI_EXT_A_SIZE=$(stat -c%s "$MI_EXT_A_IMG")
PRODUCT_A_SIZE=$(stat -c%s "$PRODUCT_A_IMG")
SYSTEM_A_SIZE=$(stat -c%s "$SYSTEM_A_IMG")
SYSTEM_EXT_A_SIZE=$(stat -c%s "$SYSTEM_EXT_A_IMG")
VENDOR_A_SIZE=$(stat -c%s "$VENDOR_A_IMG")

echo "📦 Building super image (sparse format)..."
lpmake \
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
    --output "$OUTPUT_IMAGE" || {
        echo "❌ lpmake failed!";
        exit 1;
    }

chmod 777 "$OUTPUT_IMAGE" || {
    echo "⚠️ Warning: Failed to set permissions on $OUTPUT_IMAGE (but the image was generated)";
}

# Cleaning up
rm -rf tmp/product_a
rm UKL/UnpackerSuper/mi_ext_a.img UKL/UnpackerSuper/product_a.img UKL/UnpackerSuper/system_a.img UKL/UnpackerSuper/system_ext_a.img UKL/UnpackerSuper/vendor_a.img
rm -rf UKL/UnpackerSystem/mi_ext_a UKL/UnpackerSystem/product_a UKL/UnpackerSystem/system_a UKL/UnpackerSystem/system_ext_a UKL/UnpackerSystem/vendor_a UKL/UnpackerSystem/config


echo -e "\n✅ Phase 2 Complete: Sparse super image generated at:"
echo "   → $OUTPUT_IMAGE"