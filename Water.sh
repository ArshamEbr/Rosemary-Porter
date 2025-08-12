#!/usr/bin/env expect

# =============================================================================
# Partition Builder Automation Script (Improved ver)
# Usage: ./auto.sh <script_name>
# Example: ./auto.sh ./UKL/run.sh
# =============================================================================

set timeout 120

# Get script name from command line argument
set script_name [lindex $argv 0]

if {$script_name == ""} {
    puts "Usage: $argv0 <script_name>"
    puts "Example: $argv0 ./UKL/run.sh"
    puts "Example: $argv0 python3 main.py"
    exit 1
}

# =============================================================================
# PYRO SUPER PACKER SCRIPT CONFIGURATION
# This script/command will run ONLY if all partitions build successfully (100%)
# Leave empty ("") to disable pyro super packer script execution
# =============================================================================

set success_script "./Burn.sh"

# ============================================================================= 
# PARTITION CONFIGURATION - EDIT THIS SECTION FOR YOUR PARTITIONS
# Format: {partition_name free_space_mb}
# =============================================================================

set partition_configs {
    {"system_ext_a" 200}
    {"system_a" 70}
    {"mi_ext_a" 0}
    {"vendor_a" 70}
    {"product_a" 150}
}

# Alternative: Build all images at once with the same free space size (not recommended)
# set partition_configs {
#     {"Build All Images" 1000}
# }

# =============================================================================

proc find_partition_number {target_name} {
    global expect_out
    
    puts "→ Looking for partition: '$target_name'"
    
    # Send a newline to see the current menu clearly
    send "\r"
    
    # Wait a moment for menu to display
    expect {
        "#?" {
            # Get all the output buffer
            set full_output $expect_out(buffer)
            puts "DEBUG: Menu content received"
            
            # Split into lines and examine each one
            set lines [split $full_output "\n"]
            
            foreach line $lines {
                # Clean up the line
                set clean_line [string trim $line]
                
                # Look for patterns like "1) system_ext_a" 
                if {[regexp {^(\d+)\)\s*(.+?)$} $clean_line match number name]} {
                    set clean_name [string trim $name]
                    puts "DEBUG: Found option $number: '$clean_name'"
                    
                    if {$clean_name == $target_name} {
                        puts "→ Found '$target_name' at position $number"
                        return $number
                    }
                }
            }
            
            # If exact match not found, try partial match
            foreach line $lines {
                set clean_line [string trim $line]
                if {[regexp {^(\d+)\)\s*(.+?)$} $clean_line match number name]} {
                    set clean_name [string trim $name]
                    if {[string first $target_name $clean_name] != -1} {
                        puts "→ Found partial match '$target_name' in '$clean_name' at position $number"
                        return $number
                    }
                }
            }
        }
        timeout {
            puts "✗ Timeout waiting for menu"
            return -1
        }
    }
    
    puts "✗ Partition '$target_name' not found in menu"
    return -1
}

proc build_partition {partition_name free_space} {
    puts "\n=== BUILDING: $partition_name (Free Space: ${free_space}MB) ==="
    
    # Navigate to Assembly .img menu (7)
    expect {
        "#?" { 
            send "7\r"
            puts "→ Assembly .img menu"
        }
        timeout { 
            puts "✗ Timeout waiting for main menu"
            return 0 
        }
    }
    
    # Select Build .img(raw) (2)
    expect {
        "#?" { 
            send "2\r"
            puts "→ Build .img(raw)"
        }
        timeout { 
            puts "✗ Timeout in Assembly menu"
            return 0 
        }
    }
    
    # Select build with folder size (3)
    expect {
        "#?" { 
            send "3\r"
            puts "→ Build with folder size"
        }
        timeout { 
            puts "✗ Timeout in Build menu"
            return 0 
        }
    }
    
    # Press Enter for default save folder
    expect {
        -re "Press.*Enter.*|your path.*saving folder" { 
            send "\r"
            puts "→ Default save folder"
        }
        timeout { 
            puts "✗ Timeout waiting for folder prompt"
            return 0 
        }
    }
    
    # Enter partition-specific free space
    expect {
        -re "megabytes:" { 
            send "$free_space\r"
            puts "→ Free space: ${free_space}MB"
        }
        timeout { 
            puts "✗ Timeout waiting for free space prompt"
            return 0 
        }
    }
    
    # Now we should be at the partition selection menu
    expect {
        -re "Select a build folder:" {
            puts "→ Partition selection menu detected"
            
            # Find the partition number by name
            set partition_num [find_partition_number $partition_name]
            
            if {$partition_num == -1} {
                puts "✗ Could not find partition '$partition_name'"
                # Send 7 to exit to main menu
                expect "#?" { send "7\r" }
                return 0
            }
            
            # Send the found partition number
            send "$partition_num\r"
            puts "→ Selected: $partition_name (option $partition_num)"
        }
        "#?" {
            puts "→ At partition menu (alternative path)"
            
            # Find the partition number by name
            set partition_num [find_partition_number $partition_name]
            
            if {$partition_num == -1} {
                puts "✗ Could not find partition '$partition_name'"
                # Send 7 to exit to main menu
                send "7\r"
                return 0
            }
            
            # Send the found partition number
            send "$partition_num\r"
            puts "→ Selected: $partition_name (option $partition_num)"
        }
        timeout { 
            puts "✗ Timeout waiting for partition menu"
            return 0 
        }
    }
    
    # Wait for build completion (timeout based on free space size)
    if {$free_space * 2 > 600} {
        set build_timeout [expr {$free_space * 2}]
    } else {
        set build_timeout 600
    }
    
    puts "→ Building... (timeout: [expr {$build_timeout/60}] minutes)"
    
    expect {
        -timeout $build_timeout
        "Main MENU:" { 
            puts "✓ SUCCESS: $partition_name"
            return 1 
        }
        "#?" { 
            puts "✓ COMPLETED: $partition_name"
            return 1 
        }
        timeout { 
            puts "⚠ TIMEOUT: $partition_name (may still be building)"
            return 1
        }
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

puts "Partition Builder Automation (Improved ver)"
puts "Script: $script_name"
if {$success_script != ""} {
    puts "Success script: $success_script"
}
puts "Partitions to build: [llength $partition_configs]"

exp_internal 0  # Set to 1 for detailed debugging

# Start the script
eval spawn $script_name

# Wait for main menu
expect {
    "Main MENU:" { 
        puts "✓ Script started successfully"
    }
    timeout { 
        puts "✗ Failed to start script or reach main menu"
        exit 1 
    }
}

# Build each partition
set successful 0
set failed 0
set total [llength $partition_configs]

puts "\n🚀 Starting builds..."

foreach config $partition_configs {
    set partition_name [lindex $config 0]
    set free_space [lindex $config 1]
    
    puts "\n--- Processing: $partition_name with ${free_space}MB ---"
    
    if {[build_partition $partition_name $free_space]} {
        incr successful
        puts "✅ SUCCESS: $partition_name"
    } else {
        incr failed
        puts "❌ FAILED: $partition_name"
    }
    
    # Pause between builds
    if {$successful + $failed < $total} {
        puts "→ Pausing 5 seconds..."
        sleep 3
    }
}

# Exit script
puts "\n→ Exiting..."
expect {
    "#?" { send "14\r" }
    timeout { puts "Timeout on exit, forcing close" }
}
expect eof

set success_rate [expr {$successful * 100 / $total}]

puts "\n📊 BUILD SUMMARY"
puts "================"
puts "Total: $total"
puts "Successful: $successful"
puts "Failed: $failed" 
puts "Success rate: ${success_rate}%"

if {$success_rate == 100} {
    puts "\n🎉 All builds completed successfully!"
    
    if {$success_script != ""} {
        puts "\n🚀 Running Pyro Super Packer Please Wait !!!"
        puts "================================================"
        
        # Execute the success script
        if {[catch {eval exec $success_script} result]} {
            puts "$result"
            exit 1
        } else {
            puts "$result"
            puts "\n✅ All operations completed successfully!"
            exit 0
        }
    } else {
        exit 0
    }
} else {
    puts "\n⚠ Some builds had issues - skipping success script sigh..."
    exit 1
}