#!/bin/bash


# --> csulcca-6.0.13.s390x.rpm create the required groups to load the key.


#Verify the library is installed.
function  check_panel() {
	echo " Script to set CCA master keys for all four categories"
   
	if ( ! hash panel.exe && ! hash ivp.e ); then
   		echo " The CCA host library package csulcca-6.0.13.s390x.rpm is not installed but is a prerequisite for this script."
   		exit 1
   		fi
}

# The command to detach, attach, vary on and off. 


function  list_command() {
	printf "Few How to? \n"
	printf "\t\t How to Listing crypto card? \n 
			\t ##/usr/sbin/vmcp  q crypto apqs \n 
	        How to VaryOn crypto card? \n 
			\t ##vmcp vary <on|off> crypto ap <card no> \n 
	        How to Attach Detach cryto card? \n
			\t ##vmcp <attach|detach> crypto ap <card no> domain <domain> to \*
			How to List the card from bastion? \n
			\t lszcrypt -VVV \n 
			How to Enable the card from bastion? \n 
			\t chzcrypt -e <cardno> \n 
			How to Verify the card details? \n
			\t ivp.e or panel.exe -x \n 
			How to Checking CPACF? \n
			\t panel.exe --list-cpacf \n "
}

function how_to_configure_cex_card() {
	printf " How to Configure CEX card in bastion? \n  
			 1. Verify that the CCA host library package installed csulcca-6.0.13.s390x.rpm \n\
			 2. If the crypto card shows available. \n \
			 3. Attach the card. \n \
			 4. Vary On the card. \n \
			 5. Run check_users function.\n \
			 6. Run # load_master_key <domain> <cardno> \n \
			 "
}

#Declare the variable for the present cryptocard.

#​card_no=$(ivp.e | awk '/Adapter card/ {print $4}' | tr -d [])
#dom_no=$(panel.exe -x | awk  '/Default Domain:/ {print $3}' | tr -d [])



#Verifying the crypto cards  and load with keys.
#	/usr/sbin/vmcp  q crypto apqs 
#	if [ $? -ne 0 ]; then
#		printf "Cards not present in the system."
#		exit 1
	
#	/usr/sbin/vmp q crypto apqs | grep CEX[0-9]C | grep offline > /dev/null 2&>1
	
	
#	else
#		/usr/sbin/lszcrypt > /dev/null 2&>1 
#			if [  $? -ne 0 ]; then
#				check_users
		


#function vary_on_off() {
#	parm=$1

#	card=$2
#	vmcp vary $parm crypto ap $card
#	if [ $? -ne 0 ]; then
#		printf "Crypto Varyon failed"
#		exit 1
#	fi
#	lszcrypt -VVV
#}

#function attach_detach_crypto() {
#	parm=$1
#	card=$2
#	dom=$3
#vmcp $parm crypto ap $card domain $dom to \*
#if [$? -ne 0 ]; then
#	printf " Crypto card attach failed"
#	exit 1
#fi

#lszcrypt -VVV

#}
#

function check_users() {
	for user in cca_user cca_lfmkp cca_cmkp cca_clrmk cca_setmk cca_user 
		do
		#printf "Checking user $user\n"
			id $user > /dev/nul 2>&1
			if [ $? -ne 0  ]; then
				printf "User $user does not exits! Creating user..\n"
				useradd -g cca_admin -d /home/$user -G cca_admin,$user -m $user
			fi
	done
}


function add_user() {
 useradd -g cca_admin -d /home/cca_user -m cca_user
 useradd -g cca_admin -d /home/cca_lfmkp -G cca_admin,cca_lfmkp -m cca_lfmkp
 useradd -g cca_admin -d /home/cca_cmkp -G cca_admin,cca_cmkp -m cca_cmkp
 useradd -g cca_admin -d /home/cca_clrmk -G cca_admin,cca_clrmk -m cca_clrmk
 useradd -g cca_admin -d /home/cca_setmk -G cca_admin,cca_setmk -m cca_setmk
}

function load_master_key() {
	dom=$1
	card=$2
export CSU_DEFAULT_DOMAIN=${dom}
export CSU_DEFAULT_ADAPTER=${card}

echo "panel.exe --mktype=ASYM --mk-clear" | su - cca_clrmk
echo "panel.exe --mktype=ASYM --mkpart=FIRST --mk-load=0101030405060708090A0B0C0D0E0F101112131415161718" | su - cca_lfmkp
echo "panel.exe --mktype=ASYM --mkpart=MIDDLE --mk-load=39202122232425262728292A2B2C2D2E2F30313233343536" | su - cca_cmkp
echo "panel.exe --mktype=ASYM --mkpart=LAST --mk-load=3738393A3B3C3D3E3F404142434445464748494A4B4C4D4E" | su - cca_cmkp
echo "panel.exe --mktype=ASYM --mk-set" | su - cca_setmk
echo "panel.exe --mktype=APKA --mk-clear" | su - cca_clrmk
echo "panel.exe --mktype=APKA --mkpart=FIRST --mk-load=0103030405060708090A0B0C0D0E0F1011121314151617181716151413121110" | su - cca_lfmkp
echo "panel.exe --mktype=APKA --mkpart=MIDDLE --mk-load=59202122232425262728292A2B2C2D2E2F303132333435363534333231302F2E" | su - cca_cmkp
echo "panel.exe --mktype=APKA --mkpart=LAST --mk-load=3738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4D4C4B4A49484746" | su - cca_cmkp
echo "panel.exe --mktype=APKA --mk-set" | su - cca_setmk
echo "panel.exe --mktype=SYM --mk-clear" | su - cca_clrmk
echo "panel.exe --mktype=SYM --mkpart=FIRST --mk-load=40CD51A470FE91EC7531B0A4011383FE23451F67C1A194A4" | su - cca_lfmkp
echo "panel.exe --mktype=SYM --mkpart=MIDDLE --mk-load=DFDCB01334577991ABCDEF1334577980ABCDEF1334577980" | su - cca_cmkp
echo "panel.exe --mktype=SYM --mkpart=LAST --mk-load=040404040404040404040404040404040404040404040404" | su - cca_cmkp
echo "panel.exe --mktype=SYM --mk-set" | su - cca_setmk
echo "panel.exe --mktype=AES --mk-clear" | su - cca_clrmk
echo "panel.exe --mktype=AES --mkpart=FIRST --mk-load=0302030405060708090A0B0C0D0E0F1011121314151617181716151413121110" | su - cca_lfmkp
echo "panel.exe --mktype=AES --mkpart=MIDDLE --mk-load=79202122232425262728292A2B2C2D2E2F303132333435363534333231302F2E" | su - cca_cmkp
echo "panel.exe --mktype=AES --mkpart=LAST --mk-load=1738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4D4C4B4A49484746" | su - cca_cmkp
echo "panel.exe --mktype=AES --mk-set" | su - cca_setmk
}

echo "--------------------------------------------------"
list_command
echo "--------------------------------------------------"
printf "\n"
how_to_configure_cex_card
printf "\n"
echo "--------------------------------------------------"