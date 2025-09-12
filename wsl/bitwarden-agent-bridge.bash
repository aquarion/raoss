#!/bin/bash
# From https://www.rebelpeon.com/bitwarden-ssh-agent-on-wsl2/

BW_BRIDGE=1
BW_ERROR=""

if ! hash socat 2>> /dev/null;
then
    echo "socat not found, please install it"
    BW_BRIDGE=0
    BW_ERROR="${BW_ERROR}* socat not found, please install it\n"
fi

if [[ ! -f /mnt/c/ProgramData/chocolatey/lib/npiperelay/tools/npiperelay.exe ]]; then
    echo ""
    BW_BRIDGE=0
    BW_ERROR="${BW_ERROR}* npiperelay not found, please install it in Windows with Chocolatey\n"
fi

if [[ $BW_BRIDGE -eq 0 ]]; then
    echo -e "Bitwarden Agent Bridge Failed:\n"
    echo -e "$BW_ERROR"
    exit 1
fi

export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
ss -a | grep -q $SSH_AUTH_SOCK
if [ $? -ne 0   ]; then
    rm -f $SSH_AUTH_SOCK
    ( setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"/mnt/c/ProgramData/chocolatey/lib/npiperelay/tools/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork & ) >> $HOME/.ssh/agent.log 2>>&1
fi
