hackerman() {
    theme greenscreen.dark  # Set theme to green

    random_hex() { head /dev/urandom | tr -dc 'A-F0-9' | head -c $1; }
    random_ip() { echo "$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 256))"; }
    random_port() { echo "$((RANDOM % 65535 + 1))"; }

    # Generate a random duration (1-10 seconds)
    random_duration() { echo $((RANDOM % 10 + 1)); }

    # High-Speed System Log Flood
    rapid_system_logs() {
        duration=$(random_duration)
        end=$((SECONDS + duration))
        
        while [ $SECONDS -lt $end ]; do
            printf "\033[32m[%s] %s from %s:%s\033[0m\n" \
                "$(date +%H:%M:%S)" \
                "$(random_hex 12)" \
                "$(random_ip)" \
                "$(random_port)"
            sleep 0.$((RANDOM % 3))
        done
    }

    # Wide Hex Dump Flood
    wide_data_flood() {
        duration=$(random_duration)
        end=$((SECONDS + duration))
        
        while [ $SECONDS -lt $end ]; do
            echo -e "\033[32m$(random_hex 128)\033[0m"
        done
    }

    ascii_noise_grid() {
        chars="█▓▒░■□▢▣▤▥▦▧▨▩◆◇○◎●◉◊◈◮◭▴▾△▽◅▻◃▹▰▱▲▼▶◀∇∇∇"
        duration=$(random_duration)  # Ensure random_duration function is defined
        end=$((SECONDS + duration))
        
        while [ $SECONDS -lt $end ]; do
            line=""
            for _ in {1..40}; do
                index=$((RANDOM % ${#chars}))  # Generate a valid random index
                line+="${chars:index:1} "     # Correct substring extraction
            done
            echo -e "\033[32m$line\033[0m"
            sleep 0.05
        done
    }

    glitchy_code_output() {
        codes=("int main() {" "printf(" "return 0;" "void function() {" "if (" "while (" "malloc(" "free(" "NULL;" "exit(1);" "char *str =" "int var =" "#include <stdio.h>" "#include <stdlib.h>")
        duration=$(random_duration)
        end=$((SECONDS + duration))

        while [ $SECONDS -lt $end ]; do
            line=""
            for _ in {1..6}; do
                index=$((RANDOM % ${#codes[@]}))  # Generate random valid index
                line+=" ${codes[index]} $(random_hex 4);"
            done
            echo -e "\033[32m$line\033[0m"
            sleep 0.1
        done
    }

    # File System Chaos
    filesystem_chaos() {
        duration=$(random_duration)
        end=$((SECONDS + duration))

        while [ $SECONDS -lt $end ]; do
            echo -e "\033[32m[INFO] Modifying /var/log/syslog...\033[0m"
            echo -e "\033[31m[ERROR] Corruption detected in /usr/bin/critical_file\033[0m"
            echo -e "\033[34m[INFO] chmod 777 /etc/passwd... [SUCCESS]\033[0m"
            echo -e "\033[33m[WARNING] Attempting to format /dev/sda1...\033[0m"
            echo -e "\033[35m[DEBUG] Restoring from backup... $(random_hex 8)\033[0m"
            sleep 0.2
        done
    }

    # Fullscreen Randomness
    fullscreen_randomness() {
        chars="█▓▒░■□▢▣▤▥▦▧▨▩◆◇○◎●◉◊◈◮◭▴▾△▽◅▻◃▹▰▱▲▼▶◀∇∇∇"
        duration=$(random_duration)
        end=$((SECONDS + duration))

        while [ $SECONDS -lt $end ]; do
            echo -e "\033[32m$(head /dev/urandom | tr -dc "$chars" | head -c $((RANDOM % 100 + 80)))\033[0m"
            sleep 0.03
        done
    }

    # Simulated Kernel Panic
    kernel_panic() {
        duration=$(random_duration)
        end=$((SECONDS + duration))

        while [ $SECONDS -lt $end ]; do
            echo -e "\033[31m[ KERNEL PANIC ] Kernel fault at 0x$(random_hex 8), system halted!\033[0m"
            echo -e "\033[33m[WARNING] Unable to locate memory address 0x$(random_hex 6)\033[0m"
            echo -e "\033[34m[INFO] Attempting automatic reboot...\033[0m"
            echo -e "\033[35m[DEBUG] Checking stack trace...\033[0m"
            sleep 0.3
        done
    }

      random_dmesg_output() {
        duration=$(random_duration)

        # Start a timer
        end=$((SECONDS + duration))

        # Read from /var/log/dmesg and output lines until the random duration is over
        while read line
        do
            echo "$line"
            sleep 0.1

            # Check if the random duration time has elapsed
            if [ $SECONDS -ge $end ]; then
                break
            fi
        done < /var/log/dmesg
    }


    dev_random_output() {
        duration=$(random_duration)

        # Start a timer
        end=$((SECONDS + duration))

        # Read from /dev/random and output until the random duration is over
        while [ $SECONDS -lt $end ]
        do
            # Output a small chunk of random bytes from /dev/random
            head -c 16 /dev/random | hexdump -C
        done
    }

    random_morse_code() {
        # Morse code dictionary
        morse_codes=( ".-" "-..." "-.-." "-.." "." "..-." "--." "...." ".." ".---" "-.-" ".-.." "--" "-." "---" ".--." "--.-" ".-." "..." "-" "..-" "...-" ".--" "-..-" "-.--" "--.." )
        
        # Generate a random number between 1 and 10 for the duration
        duration=$(random_duration)
        end=$((SECONDS + duration))

        while [ $SECONDS -lt $end ]
        do
            # Randomly choose letters and print their Morse code equivalent
            char=$((RANDOM % 26))  # Random letter from A-Z
            echo -n "${morse_codes[$char]} "
            sleep 0.2
        done
    }

     random_matrix_output() {
        printf "\e[32m\n"
        # Generate a random number between 1 and 10 for the duration
        duration=$((RANDOM % 10 + 1))

        # Start a timer
        end=$((SECONDS + duration))

        # Run the loop until the random duration is over
        while [ $SECONDS -lt $end ]
        do
            v=""
            for i in {1..32}
            do
                ((r = RANDOM % 2))
                if ((RANDOM % 5 == 1))
                then
                    if ((RANDOM % 4 == 1))
                    then
                        v+="\e[1m $r   "
                    else
                        v+="\e[2m $r   "
                    fi
                else
                    v+="     "
                fi
            done
            printf "$v\n"
            v=""
        done
    }


    # Infinite Loop with Randomized Variations
    while true; do
        case $((RANDOM % 10)) in
            0) wide_data_flood ;;
            1) rapid_system_logs ;;
            2) ascii_noise_grid ;;
            3) glitchy_code_output ;;
            4) filesystem_chaos ;;
            5) fullscreen_randomness ;;
            6) kernel_panic ;;
            7) random_matrix_output ;;
            8) random_dmesg_output ;;
            9) random_morse_code ;;
        esac
    done
}

