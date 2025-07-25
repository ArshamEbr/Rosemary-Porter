#!/run/current-system/sw/bin/bash

# Configuration
SCRIPTS=(
    "scripts/Pyro_debloater.sh"               # Interactive script 1
    "scripts/Pyro_product_prop_builder.sh"    # Non-interactive
    "scripts/Pyro_copier.sh"                  # Interactive script 2
    "scripts/Pyro_miext_mover.sh"             # Interactive script 3
    "scripts/Pyro_miext_prop_builder.sh"
    "scripts/Pyro_system_prop_builder.sh"
    "scripts/Pyro_system_ext_prop_builder.sh"
)

# Options
STOP_ON_ERROR=true          # Stop on first failure
SHOW_PROMPTS=true           # Display interactive prompts
LOG_FILE="sequence_$(date +%Y%m%d_%H%M%S).log"

# -- Execution Setup --
bold=$(tput bold)
normal=$(tput sgr0)
total=${#SCRIPTS[@]}
completed=0

echo "${bold}Starting script sequence (${total} steps)${normal}"

# -- Execution Function --
run_script() {
    local script=$1
    echo -e "\n${bold}[Step $((completed+1))/${total}] ${script}${normal}"
    
    # Check script validity
    if [[ ! -f "$script" ]]; then
        echo "  ${bold}Error:${normal} Missing script: $script"
        return 1
    fi
    if [[ ! -x "$script" ]]; then
        echo "  ${bold}Error:${normal} Not executable: $script"
        return 1
    fi

    # Interactive mode handling
    if $SHOW_PROMPTS; then
        echo "  ${bold}Interactive mode${normal} - monitor for prompts!"
        script -q -c "$script" -a "$LOG_FILE"
    else
        echo "  ${bold}Non-interactive mode${normal} - may hang on prompts!"
        "$script" >> "$LOG_FILE" 2>&1
    fi

    return $?
}

# -- Main Sequence --
for script in "${SCRIPTS[@]}"; do
    if $SHOW_PROMPTS; then
        run_script "$script"
    else
        run_script "$script" </dev/null  # Prevent hanging in non-interactive
    fi
    
    exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo "  ${bold}Failed${normal} with code $exit_code"
        $STOP_ON_ERROR && exit 1
    else
        ((completed++))
    fi
done

# -- Final Report --
echo -e "\n${bold}PyroOS completed${normal}"
echo "Successful steps: ${completed}/${total}"
[[ $completed -eq $total ]] && exit 0 || exit 1