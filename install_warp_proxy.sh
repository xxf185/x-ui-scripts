#!/bin/bash


AUTHOR="[xxf185](https://github.com/xxf185)"
VERSION="1.2.0"


#
# Version: 1.2.0
# Date Created: 2023-04-18
# Date Modified: 2023-05-30
# 
# Script: install_warp_proxy.sh
# 
# Description:
#   This script installs Warp Socks5 Proxy (WireProxy) for your system.
#   WireProxy is a secure and fast proxy service that routes your network traffic through Cloudflare's global network.
# 
# Author: [xxf185](https://github.com/xxf185)
# 
# Usage: bash ./install-warp-proxy.sh [-y] [-f]
# 
# Options:
#   -y      Accept default inputs.
#   -f      Force reinstallation of Warp Socks5 Proxy (WireProxy) even if it's already installed.
# 
# Note:
#   By default, the script checks whether Warp Socks5 Proxy (WireProxy) is already installed before proceeding.
#   Use the -y option to accept defaults.
#   Use the -f option to force reinstallation.
# 
# Thanks To: [fscarmen](https://github.com/fscarmen)
# 
# Supported OS:
#   1. Ubuntu
#   2. Debian
#   3. CentOS
#   4. Alpine
#   5. Arch
#   6. Oracle
#   7. Alma
#   8. Rocky
# 
# One-Line Command for installation: (use of this commands)
#   not-forced: `curl -fsSL https://raw.githubusercontent.com/xxf185/x-ui-scripts/main/install_warp_proxy.sh | bash`
#   not-forced: `bash <(curl -sSL https://raw.githubusercontent.com/xxf185/x-ui-scripts/main/install_warp_proxy.sh)`
#   forced: `bash <(curl -sSL https://raw.githubusercontent.com/xxf185/x-ui-scripts/main/install_warp_proxy.sh) -yf`
# 


# Define colors
red="\e[31m\e[01m"
blue="\e[36m\e[01m"
green="\e[32m\e[01m"
yellow="\e[33m\e[01m"
bYellow="\e[1;33m"
plain="\e[0m"


# Draw ASCII-ART
function draw_ascii_art() {
  echo -e "
   ____  ____       _       ____    ____  _____  ______              ______  ____  ____    
  |_   ||   _|     / \     |_   \  /   _||_   _||_   _ \`.          .' ___  ||_   ||   _|  
    | |__| |      / _ \      |   \/   |    | |    | | \`. \ ______ / .'   \_|  | |__| |    
    |  __  |     / ___ \     | |\  /| |    | |    | |  | ||______|| |   ____  |  __  |     
   _| |  | |_  _/ /   \ \_  _| |_\/_| |_  _| |_  _| |_.' /        \ \`.___]  |_| |  | |_   
  |____||____||____| |____||_____||_____||_____||______.'          \`._____.'|____||____|  
  "
}


# ===============================
# ********** Variables **********
# ===============================
# General Variables
CAN_USE_TPUT=$(command -v tput >/dev/null 2>&1 && echo "true" || echo "false")
USE_DEFAULT="false"
FORCE="false"
SPIN_TEXT_LEN=0
SPIN_PID=
WP_INSTALL_PORT="40000"
WP_LISTENING_PORT=


# Status Variables
# STEP_STATUS ==>  (0: failed) | (1: success) 
# WP_STATUS ==>  (0: not installed) | (1: off) | (2: on)
STEP_STATUS=1
WP_STATUS=0


# OS Variables
OS_SYS=
OS_INDEX=
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Alpine" "Arch")
RELEASE_REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "amazon linux" "alpine" "arch linux")
PKG_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update" "apk update -f" "pacman -Sy")
PKG_INSTALL=("apt -y --fix-broken install" "apt -y --fix-broken install" "yum -y install" "yum -y install" "apk add -f --no-cache" "pacman -S --noconfirm")


# ===============================
# *********** Message ***********
# ===============================
declare -A T
# base
T[000]="选项需要参数:"
T[001]="无效选项:"
T[002]="选择无效."
T[003]=""
T[004]=""
T[005]="[INFO]"
T[006]="[ALERT]"
T[007]="[ERROR]"
T[008]="[DEBUG]"
T[009]="[WARNING]"
# intro
T[010]="感谢您使用此脚本来安装 warp. \n  如果您觉得这个脚本有用，请在 github 上给一个 star!"
T[011]="版本:"
T[012]="作者:"
T[013]=""
T[014]="选项:"
T[015]="接受默认值。"
T[016]="强制重新安装 Warp Socks5 代理 (WireProxy)。"
T[017]=""
T[018]=""
T[019]=""
T[020]="有用的命令:"
T[021]="卸载Warp"
T[022]="更改 Warp 帐户类型（免费、附加……）"
T[023]="打开/关闭 WireProxy"
T[024]=""
T[025]=""
T[026]=""
T[027]=""
T[028]=""
T[029]=""
T[030]=""
T[031]=""
T[032]=""
T[033]=""
T[034]=""
T[035]=""
T[036]=""
T[037]=""
T[038]=""
T[039]=""
# show_warnings
T[040]="您正在使用此选项:"
T[041]="接受默认值"
T[042]="强制重新安装 Warp Socks5 Proxy (WireProxy)"
T[043]=""
T[044]=""
T[045]=""
T[046]=""
T[047]=""
T[048]=""
T[049]=""
# prompts
T[050]="默认"
T[051]="超过最大尝试次数。 正在退出..."
T[052]="剩余尝试次数:"
T[053]="最后一次尝试！ 剩余尝试:"
T[054]="请输入端口"
T[055]="哎呀！ 输入无效。 请输入 1 到 65535 之间的端口。"
T[056]="哎呀！ 该端口已被使用。 请选择 1 到 65535 之间的其他端口！"
T[057]="WireProxy"
T[058]=""
T[059]=""
# check_root
T[060]="正在验证 root访问权限..."
T[061]="请以 root用户运行此脚本！"
T[062]="好消息！已是root用户.继续.."
# check_os
T[063]="正在验证您的操作系统是否受支持..."
T[064]="不支持您的操作系统! \n  该脚本仅支持 Debian、Ubuntu、CentOS、Arch 或 Alpine 系统.\n"
T[065]="您的操作系统与此安装兼容。继续..."
# install_base_packages
T[066]="正在为您的操作系统安装必要的软件包..."
T[067]="安装软件包时出错！ \n  请检查您的连接或稍后重试。"
T[068]="所有必需的软件包已成功安装。"
# warp_command
T[069]="检查 [warp] 命令快捷方式是否存在，并在必要时创建它..."
T[070]="创建[warp]命令快捷方式失败！ 请稍后再试。"
T[071]="[warp] 命令快捷方式创建成功。"
T[072]="[warp] 命令快捷方式已设置。"
# warp_status
T[073]="查看 WARP 状态..."
T[074]="WARPocks5 代理 (WireProxy) 已安装并当前正在运行。 \n WARP 正在socks5://127.0.0.1 上监听："
T[075]="WARP sock5 代理 (WireProxy) 已安装，但当前未运行。"
T[076]="尚未安装 WARPocks5 代理 (WireProxy)"
# install_warp
T[077]="正在安装 WARPocks5 代理 (WireProxy)..."
T[078]="WARPocks5 代理 (WireProxy)安装失败！ 请稍后再试。"
T[079]=" WARPocks5代理（WireProxy）已安装并可以使用。 \n WARP 正在socks5://127.0.0.1 上监听："
# start_warp
T[080]="激活 WARPocks5 代理 (WireProxy)..."
T[081]="WARPocks5代理（WireProxy）启动失败！ 请稍后再试。"
T[082]="WARP sock5 代理 (WireProxy) 处于活动状态并正在监听ocks5://127.0.0.1："
# confirm reinstall_warp
T[083]="重新安装 WARPocks5 代理吗?"
# reinstall_warp
T[084]="正在执行 WARPocks5 代理 (WireProxy) 的全新安装..."
T[085]="WARPocks5 代理 (WireProxy)安装失败！ 请稍后再试。"
T[086]="WARPocks5代理（WireProxy）已重新安装并可以使用。 \n WARP 正在socks5://127.0.0.1 上监听："
T[087]=""
T[088]=""
T[089]=""
T[090]=""
T[091]=""
T[092]=""
T[093]=""
T[094]=""
T[095]=""
T[096]=""
T[097]=""
T[098]=""
T[099]=""
T[100]=""


# ===============================
# ******** Base Function ********
# ===============================
# Get Options
while getopts ":yf" opt; do
  case ${opt} in
    f)
      FORCE="true"
      ;;
    y)
      USE_DEFAULT="true"
      ;;
    :)
      echo -e "  ${red}${T[000]} -${OPTARG}${plain}" 1>&2
      exit 1
      ;;
    \?)
      echo -e "  ${red}${T[001]} -${OPTARG}${plain}" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))


function escaped_length() {
  # escape color from string
  local str="${1}"
  local stripped_len=$(echo -e "${str}" | sed 's|\x1B\[[0-9;]\{1,\}[A-Za-z]||g' | tr '\n' ' ' | wc -m)
  echo ${stripped_len}
}


function draw_line() {
  local line=""
  local width=$(( ${COLUMNS:-${CAN_USE_TPUT:+$(tput cols)}:-92} ))
  line=$(printf "%*s" "${width}" | tr ' ' '_')
  echo "${line}"
}


function confirm() {
  local question="${1}"
  local options="${2:-Y/n}"
  local RESPONSE=""
  read -rep "  > ${question} [${options}] " RESPONSE
  RESPONSE=$(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]') || return
  if [[ -z "${RESPONSE}" ]]; then
    case "${options}" in
      "Y/n") RESPONSE="y";;
      "y/N") RESPONSE="n";;
    esac
  fi
  # return (yes=0) (no=1)
  case "${RESPONSE}" in
    "y"|"yes") return 0;;
    "n"|"no") return 1;;
    *)
      echo -e "${red}${T[002]}${plain}"
      confirm "${question}" "${options}"
      ;;
  esac
}


function run_step() {
  {
    $@
  } &> /dev/null
}


# Spinner Function
function start_spin() {
  local spin_chars='/-\|'
  local sc=0
  local delay=0.1
  local text="${1}"
  SPIN_TEXT_LEN=$(escaped_length "${text}")
  # Hide cursor
  [[ "${CAN_USE_TPUT}" == "true" ]] && tput civis
  while true; do
    printf "\r  [%s] ${text}"  "${spin_chars:sc++:1}"
    sleep ${delay}
    ((sc==${#spin_chars})) && sc=0
  done &
  SPIN_PID=$!
  # Show cursor
  [[ "${CAN_USE_TPUT}" == "true" ]] && tput cnorm
}


function kill_spin() {
  kill "${SPIN_PID}"
  wait "${SPIN_PID}" 2>/dev/null
}


function end_spin() {
  local text="${1}"
  local text_len=$(escaped_length "${text}")
  run_step "kill_spin"
  if [[ ! -z "${text}" ]]; then
    printf "\r  ${text}"
    # Due to the preceding space in the text, we append '6' to the total length.
    printf "%*s\n" $((${SPIN_TEXT_LEN} - ${text_len} + 6)) ""
  fi
  # Reset Status
  STEP_STATUS=1
}


# Clean up if script terminated.
function clean_up() {
  # Show cursor && Kill spinner
  [[ "${CAN_USE_TPUT}" == "true" ]] && tput cnorm
  end_spin ""
}
trap clean_up EXIT TERM SIGHUP SIGTERM SIGKILL


# Check OS Function
function get_os_release() {
  local RELEASE_OS=
  local RELEASE_CMD=(
    "$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)"
    "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)"
    "$(lsb_release -sd 2>/dev/null)"
    "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)"
    "$(grep . /etc/redhat-release 2>/dev/null)"
    "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')"
  )

  for i in "${RELEASE_CMD[@]}"; do
    RELEASE_OS="${i}" && [[ -n "${RELEASE_OS}" ]] && break
  done

  echo "${RELEASE_OS}"
}


# Prompt Function
function prompt_port() {
  local for_text="${1}"
  local var_text="${2}"
  local attempts="${3:-0}"
  local check_occupied="${4:-false}"
  local default_port=""
  local error_msg=""

  # set defaults
  eval "default_port=\"\$${var_text}\""
  local ports_str="${default_port}"

  # remaining attempts
  local current_attempt=1
  local remaining_attempts=$((attempts - current_attempt + 1))
  local remaining_msg=""

  # array commands to check port occupation
  local check_cmds=(
    "ss:-nltp | grep -q"
    "lsof:-i"
  )

  # loop to get a correct port
  while true; do
    # reset error msg
    error_msg=""

    # calculate remaining attempts to show user
    remaining_attempts=$((attempts - current_attempt + 1))
    if [[ $remaining_attempts -gt 1 ]]; then
      remaining_msg="(${T[052]} ${remaining_attempts})"
    else
      remaining_msg="(${T[053]} ${remaining_attempts})"
    fi

    # ask user for input
    read -rep "  ${T[054]} ${for_text} (1-65535): `echo $'\n  > '` ${for_text} [${T[050]} '${default_port}'] ${remaining_msg}: " ports_str

    # Set default if input is empty
    if [[ -z "$ports_str" ]]; then
      ports_str=${default_port}
    fi

    # Check if port is a valid number between 1 and 65535
    is_invalid="false"
    if [[ ! "${ports_str}" =~ ^[0-9]+$ || ${ports_str} -lt 1 || ${ports_str} -gt 65535 ]]; then
      is_invalid="true"
      error_msg="${T[055]}"
    fi

    # Check if port is occupied
    if [[ "${check_occupied}" == "true" ]]; then
      for cmd_arg in "${check_cmds[@]}"; do
        IFS=':' read -r cmd args <<< "${cmd_arg}"
        if command -v "${cmd}" &> /dev/null; then
          if eval "${cmd} ${args} \":${ports_str}\"" &> /dev/null; then
            is_invalid="true"
            error_msg="${T[056]}"
            break
          fi
        fi
      done
    fi

    # if port is valid, set value and then break the loop
    if [[ "${is_invalid}" == "false" ]]; then
      eval "${var_text}=\$ports_str"
      break
    fi

    # check attempts
    if [[ ${attempts} -gt 0 && ${current_attempt} -ge ${attempts} ]]; then
      echo -e "  ${red}${T[051]}${plain}" 1>&2
      exit 1
    fi
    current_attempt=$((current_attempt + 1))

    # if invalid, show error
    echo -e "  ${red}${error_msg}${plain}"
  done
}


# ===============================
# ********** BaseSteps **********
# ===============================
function step_check_os() {
  for ((OS_INDEX=0; OS_INDEX<${#RELEASE_REGEX[@]}; OS_INDEX++)); do
    [[ $(get_os_release | tr '[:upper:]' '[:lower:]') =~ ${RELEASE_REGEX[OS_INDEX]} ]] \
    && export OS_SYS="${RELEASE[OS_INDEX]}" \
    && [ -n "${OS_SYS}" ] && break
  done
}


function step_install_pkgs() {
  {
    case "${OS_SYS}" in
      "Arch")
        ${PKG_UPDATE[OS_INDEX]}
        ;;
      *)
        ${PKG_UPDATE[OS_INDEX]}
        ${PKG_INSTALL[OS_INDEX]} wget net-tools
        ;;
    esac
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
}


function step_create_command() {
  {
    mkdir -p /etc/wireguard
    wget -N -P /etc/wireguard https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh
    chmod +x /etc/wireguard/menu.sh
    ln -sf /etc/wireguard/menu.sh /usr/bin/warp
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
}


function step_check_status() {
  WP_STATUS=0
  if [[ $(type -p wireproxy) ]]; then
    WP_STATUS=1
    if [[ $(ss -nltp) =~ wireproxy ]]; then
      WP_STATUS=2
      WP_LISTENING_PORT=$(ss -nltp | grep 'wireproxy' | awk '{print $(NF-2)}' | cut -d: -f2)
    fi
  fi
}


function step_install_warp() {
  warp w <<< $'1\n1\n'"${WP_INSTALL_PORT}"$'\n1\n'
  [[ $? -ne 0 ]] && STEP_STATUS=0 || STEP_STATUS=1
}


function step_start_warp() {
  systemctl start wireproxy
  sleep 2
}


function step_reinstall_warp() {
  {
    warp u <<< $'y\n'
    run_step "step_create_command"
    warp w <<< $'1\n1\n'"${WP_INSTALL_PORT}"$'\n1\n'
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0 || STEP_STATUS=1
}


# ===============================
# ************ Steps ************
# ===============================
function intro() {
  echo -e "${blue}
$(draw_line)
$(draw_line)
$(draw_ascii_art)
${plain}
  ${green}${T[011]}${plain} ${bYellow}${VERSION}${plain}
  ${green}${T[012]}${plain} ${bYellow}${AUTHOR}${plain}

  ${blue}${T[010]}${plain}

  ${red}${T[014]}${plain}
    ${green}-y${plain}     => ${bYellow}${T[015]}${plain}
    ${green}-f${plain}     => ${bYellow}${T[016]}${plain}

  ${red}${T[020]}${plain}
    ${green}warp u${plain} => ${bYellow}${T[021]}${plain}
    ${green}warp a${plain} => ${bYellow}${T[022]}${plain}
    ${green}warp y${plain} => ${bYellow}${T[023]}${plain}
${blue}
$(draw_line)
$(draw_line)
${plain}"
}


function show_warnings() {
  local should_show="false"
  local alert_msgs=()
  local alert_vars=(
    "USE_DEFAULT:-y:T[041]"
    "FORCE:-f:T[042]"
  )

  # loop through options variables and check if they exist, add to final message
  for alert in "${alert_vars[@]}"; do
    IFS=':' read -r var option message <<< "${alert}"
    if [[ "${!var}" == "true" ]]; then
      should_show="true"
      alert_msgs+=("    ${red}${option}${plain}   =>   ${blue}${!message}${plain}")
    fi
  done

  # if there is any message to show, echo it
  if [[ "${should_show}" == "true" ]]; then
    echo -e "  ${yellow}${T[006]} ${T[040]}${plain}"
    for msg in "${alert_msgs[@]}"; do
      echo -e "${msg}"
    done
    echo ""
  fi
}


function check_root() {
  start_spin "${yellow}${T[060]}${plain}"
  [[ $EUID -ne 0 ]] && end_spin "${red}${T[007]} ${T[061]}${plain}" && exit 1
  end_spin "${green}${T[062]}${plain}"
}


function check_os() {
  start_spin "${yellow}${T[063]}${plain}"
  run_step "step_check_os"
  if [[ -z "${OS_SYS}" ]]; then
    end_spin "${red}${T[007]} ${T[064]}${plain}" && exit 1
  fi
  if echo "${OS_SYS}" | grep -qiE "debian|ubuntu"; then
    export DEBIAN_FRONTEND="noninteractive"
  fi
  end_spin "${green}${T[065]}${plain}"
}


function prompt_all() {
  local attempts=5
  local check_occupied=$( [[ "${WP_STATUS}" == "0" ]] && echo "true" || echo "false" )
  [[ "${USE_DEFAULT}" == "false" ]] && prompt_port "${T[057]}" "WP_INSTALL_PORT" "${attempts}" "${check_occupied}"
}


function install_base_packages() {
  start_spin "${yellow}${T[066]}${plain}"
  run_step "step_install_pkgs"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[067]}${plain}" && exit 1
  fi
  end_spin "${green}${T[068]}${plain}"
}


function warp_command() {
  start_spin "${yellow}${T[069]}${plain}"
  if ! command -v warp &> /dev/null; then
    run_step "step_create_command"
    if [[ "${STEP_STATUS}" -eq 0 ]]; then
      end_spin "${red}${T[007]} ${T[070]}${plain}" && exit 1
    fi
    end_spin "${green}${T[071]}${plain}"
  else
    end_spin "${green}${T[072]}${plain}"
  fi
}


function warp_status() {
  start_spin "${yellow}${T[073]}${plain}"
  run_step "step_check_status"
  case "${WP_STATUS}" in
    2)
      end_spin "${green}${T[074]}${WP_LISTENING_PORT}${plain}"
      ;;
    1)
      end_spin "${yellow}${T[075]}${plain}"
      ;;
    0)
      end_spin "${yellow}${T[076]}${plain}"
      ;;
  esac
}


function install_warp() {
  start_spin "${yellow}${T[077]}${plain}"
  run_step "step_install_warp"
  run_step "step_check_status"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[078]}${plain}" && exit 1
  fi
  end_spin "${green}${T[079]}${WP_LISTENING_PORT}${plain}\n"
}


function start_warp() {
  start_spin "${yellow}${T[080]}${plain}"
  run_step "step_start_warp"
  run_step "step_check_status"
  if [[ "${WP_STATUS}" -ne 2 ]]; then
    end_spin "${red}${T[007]} ${T[081]}${plain}" && exit 1
  fi
  end_spin "${green}${T[082]}${WP_LISTENING_PORT}${plain}\n"
}


function reinstall_warp() {
  start_spin "${yellow}${T[084]}${plain}"
  run_step "step_reinstall_warp"
  run_step "step_check_status"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[085]}${plain}" && exit 1
  fi
  end_spin "${green}${T[086]}${WP_LISTENING_PORT}${plain}\n"
}


# ===============================
# ************* Run *************
# ===============================
clear
intro
show_warnings
check_root
check_os
install_base_packages
warp_command
warp_status
case "${WP_STATUS}" in
  0)
    prompt_all
    install_warp
    ;;
  1|2)
    [[ "${FORCE}" == "false" ]] && ! confirm "${T[083]}" "y/N" && exit 0
    prompt_all
    reinstall_warp
    run_step "step_check_status"
    [[ "${WP_STATUS}" -eq 1 ]] && start_warp
    ;;
esac


# END
clean_up
# END

