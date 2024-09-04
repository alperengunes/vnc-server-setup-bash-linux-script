#!/bin/bash

# Terminal settings for neon purple background
clear
tput civis  # Hide cursor
tput setab 5  # Set background color to purple
tput setaf 14  # Set foreground color to bright cyan (neon effect)
tput bold  # Make text bold
tput clear  # Clear the screen

# Center function for aligning text in the center of the screen
center() {
    local termwidth=$(tput cols)
    local padding=$(( (termwidth - ${#1}) / 2 ))
    printf '%*s\n' "$((padding + ${#1}))" "$1"
}

# ASCII Airplane Logo function VNC Setup
print_logo() {
    center "**********************************************"
    center "*                                            *"
    center "*             __|__                          *"
    center "*------@--@--@--(_)--@--@--@------           *"
    center "*                |                           *"
    center "*                                            *"
    center "*                                            *"
    center "*             				 *"
    center "*                                            *"
    center "**********************************************"
}

# Header function
header() {
    print_logo
    center "************* VNC Setup *************"
    center ""
}

# Spinner function for displaying loading animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local i=0
    local termwidth=$(tput cols)
    local msg="Starting VNC session :$2"
    local msgwidth=${#msg}
    local padding=$(( (termwidth - msgwidth) / 2 ))

    # Display spinner until process finishes
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr:i++%${#spinstr}:1}
        printf "\r%*s $temp" "$padding" "$msg"
        sleep "$delay"
    done
    printf "\r%*s [✔]\n" "$padding" "$msg"
}

# Start VNC function
start_vnc() {
    local display=$1
    local geometry=$2

    vncserver :$display -geometry $geometry -depth 24 -localhost no -rfbport 590$display -BlacklistTimeout 0 -BlacklistThreshold 1000000 > /dev/null 2>&1 &
    local pid=$!
    spinner "$pid" "$display"
}


# Stop VNC function
stop_vnc() {
    local display=$1

    vncserver -kill :$display > /dev/null 2>&1
    local msg="VNC session :$display stopped"
    center "$msg [✔]"
}

# Display the header
header

# Ask whether to start or stop VNC screens
center "Do you want to start or stop VNC screens?"
center "1) Start screens"
center "2) Stop screens"
read -p "$(center 'Enter your choice (1 or 2): ')" choice

case "$choice" in
    1)
        # Ask the user how many screens they want to start
        center "How many VNC screens would you like to start?"
        num_screens_prompt="Enter the number of screens:"
        center "$num_screens_prompt"
        read -p "$(center ' ')" num_screens

        # Validate input
        if ! [[ "$num_screens" =~ ^[0-9]+$ ]] || [ "$num_screens" -le 0 ]; then
            center "Invalid number. Please enter a positive integer."
            exit 1
        fi

        # Start VNC sessions based on user input
        center "Starting $num_screens VNC sessions..."

        for (( i=1; i<=num_screens; i++ )); do
            start_vnc "$i" "1280x800"
            sleep 1  # Delay between sessions
        done

        # Wait a bit to ensure all VNC sessions start properly
        sleep 2  # Adjust this delay if needed

        # Centered completion messages
        center ""
        center "All VNC sessions have started successfully!"
        ;;

    2)
        # Ask which screens to stop
        center "Which VNC screens would you like to stop?"
        stop_screens_prompt="Enter the screen numbers separated by space:"
        center "$stop_screens_prompt"
        read -p "$(center ' ')" -a screens

        # Stop the specified VNC sessions
        for screen in "${screens[@]}"; do
            stop_vnc "$screen"
        done

        center ""
        center "Selected VNC sessions have been stopped successfully!"
        ;;

    *)
        center "Invalid choice. Please enter 1 or 2."
        exit 1
        ;;
esac

center "Press any key to exit the setup..."
# Hold the screen until a keypress
read -n 1 -s  # Wait for a single keypress

# Return terminal to normal settings
tput clear
tput sgr0  # Reset terminal
tput cnorm  # Show cursor again
