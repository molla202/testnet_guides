#!/bin/bash
source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/common.sh)

while getopts u:b:v:n:o:p:h:i:r: flag; do
  case "${flag}" in
  u) UPD_HEIGHT=$OPTARG ;;
  b) BINARY=$OPTARG ;;
  v) VERSION=$OPTARG ;;
  n) NEW_BIN_PATH=$OPTARG ;;
  o) OLD_BIN_PATH=$OPTARG ;;
  p) PROJECT_NAME=$OPTARG ;;
  h) PROJECT_HOME=$OPTARG ;;
  i) CHAIN_ID=$OPTARG ;;
  r) PORT_RPC=$OPTARG ;;
  *) echo "WARN: unknown parameter: ${OPTARG}"
  esac
done

printLogo
while true; do
    VER=$($NEW_BIN_PATH version)

    if [[ -n $VER ]]; then
        # the binary is present, we proceed to auto-update
        echo -e "New Bin version: $GREEN $VER ${NC}"
        echo -e "HOME path: $GREEN $PROJECT_HOME ${NC}"
        echo -e "RPC port: $GREEN $PORT_RPC ${NC}"
        echo -e "NEW bin path: $GREEN $NEW_BIN_PATH ${NC}"
        echo -e "bin path: $GREEN $OLD_BIN_PATH ${NC}"
        break
    else
        echo -e "$RED The binary file is missing. Please BUILD the binary first and then run this script again. ${NC}"
        sleep 5
    fi
done

printLine
echo -e "YOUR NODE WILL BE UPDATED AT HEIGHT $GREEN $UPD_HEIGHT ${NC} to $GREEN ${VER} ${NC}"
printLine
echo -e "Don't kill the session with $RED CTRL+C ${NC} before update completed"
echo -e "if you want to disconnect the session use $GREEN CTRL+B D ${NC}"
printLine
sleep 2
for((;;)); do
  #height=$(${BINARY} status |& jq -r .SyncInfo.latest_block_height)
  height=$(curl -s localhost:$PORT_RPC/status | jq -r .result.sync_info.latest_block_height)
    if ((height==$UPD_HEIGHT)); then
      sudo mv $NEW_BIN_PATH $OLD_BIN_PATH
      sudo systemctl restart $BINARY
      printLine
      echo -e "$GREEN Your node has been updated and restarted, the session will be terminated automatically after 15 min${NC}"   
      printLine
    break
  else
      echo $height
  fi
  sleep 4
done
echo "$(date): Your node successfully upgraded to v${VER}" >> $PROJECT_HOME/upgrade.log
sleep 900
tmux kill-session
