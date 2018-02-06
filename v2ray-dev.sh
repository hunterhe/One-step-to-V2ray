#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: Ubuntu 14.04+
#	Version: 0.0.1
#	Blog: johnpoint.github.io
#	Author: johnpoint
#    USE AT YOUR OWN RISK!!!
#    Publish under GNU General Public License v2
#=================================================

sh_ver="0.0.1"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
Separator_1="——————————————————————————————"
 
 #Disable China
Disable_China(){
 wget http://iscn.kirito.moe/run.sh 
 bash run.sh 
 if [[ $area == cn ]];then 
 echo "Unable to install in china" 
 exit 
 fi 
 }
 
 #Check Root 
 [ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; } 
  
 Install_Basic_Packages(){
 apt update
 apt install curl wget unzip ntp jq ntpdate -y 
  }
  
 Set_DNS(){
 echo "nameserver 8.8.8.8" > /etc/resolv.conf 
 echo "nameserver 8.8.4.4" >> /etc/resolv.conf 
  }
  
 Update_NTP_settings(){
 rm -rf /etc/localtime 
 ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
 ntpdate us.pool.ntp.org
 }
 
 Disable_SELinux(){
 if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then 
 sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 
 setenforce 0 
 fi 
 }
 
 
 Update_shell(){
	echo -e "当前版本为 [ ${Green_font_prefix}${sh_ver}${Font_color_suffix} ]，开始检测最新版本..."
	sh_new_ver=$(wget --no-check-certificate -qO- "https://github.com/johnpoint/One-step-to-V2ray/raw/master/v2ray-dev.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && exit 0
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "发现新版本[ ${Green_font_prefix}${sh_new_ver}${Font_color_suffix} ]，是否更新？[y/n]"
		stty erase '^H' && read -p "(默认: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [yY] ]]; then
			rm -rf v2ray-dev.sh
			wget https://github.com/johnpoint/One-step-to-V2ray/raw/master/v2ray-dev.sh
			echo -e "脚本已更新为最新版本[ ${Green_font_prefix}${sh_new_ver}${Font_color_suffix} ] !"
            chmod +x v2ray-dev.sh
            ./v2ray.sh
            exit
		else
			echo && echo "	已取消..." && echo
		fi
	else
		echo -e "当前已是最新版本[ ${Green_font_prefix}${sh_new_ver}${Font_color_suffix} ] !"
	fi
}

To_base(){
rm -rf v2ray-dev.sh
wget https://github.com/johnpoint/One-step-to-V2ray/raw/master/v2ray-base.sh && chmod +x v2ray-base.sh && ./v2ray-base.sh
}

 Start(){
 echo -e "${Info} 正在开启v2ray"
service v2ray start 
}

Stop(){
 echo -e "${Info} 正在关闭v2ray"
service v2ray stop
}

Restart(){
Stop
Start
}

Status(){
service v2ray status
}
 
 Set_iptables(){}

Get_ip(){
Ip=$( curl ipinfo.io | jq -r '.ip' )
}

############
#	全局设置	#
###########
 
 Set_type(){
 echo -e "
 ${Tip}目前仅支持Vmess,Socks,其他服务类型可能会出现异常
请选择服务类型：
1.Shadowsocks
2.Vmess
3.socks
"
read ctype
if [[ ${ctype} == '1' ]]; then
	echo "	——————————————————————
	服务类型：Shadowsocks
	——————————————————————"
	Install_Shadowsocks
elif [[ ${ctype} == '2' ]]; then
	echo "	——————————————————————
	服务类型：Vmess
	——————————————————————"
	Install_vmess
elif [[ ${ctype} == '3' ]]; then
	echo "	——————————————————————
	服务类型：Socks
	——————————————————————"
	Install_socks
else
	echo "选择1，2或3"
	exit 0
fi
}

Log_lv(){
echo "请输入日志等级：
1.debug
2.info
3.warning(默认)
4.error
5.none
"
echo "输入：" && read setlv
[[ -z "${setlv}" ]] && setlv="3"
if [[ ${setlv} == '1' ]]; then
	loglv='debug'
elif [[ ${setlv} == '2' ]]; then
	loglv='info'
elif [[ ${setlv} == '3' ]]; then
	loglv='warning'
elif [[ ${setlv} == '4' ]]; then
	loglv='error'
elif [[ ${setlv} == '5' ]]; then
	loglv='none'
else
	echo -e "${Error} 输入错误！"
	Log_lv
fi
echo "	——————————————————————
	日志等级：${loglv}
	——————————————————————"
	
echo "设置日志路径"
echo "access路径"
read save_access
echo "error路径"
read save_error
}

 Port_main(){
 read -p "输入主要端口（默认：32000）:" port 
 [ -z "$port" ] && port=32000
 echo "	——————————————————————
	主要端口：${port}
	——————————————————————"
 }
 
 Set_uuid(){
 echo -e "请输入自定义UUID,如需新生成请留空"
 read uuid
 [[ -z ${uuid} ]] && uuid=$(cat /proc/sys/kernel/random/uuid) 
 echo "	——————————————————————
 	UUID: ${uuid}
 	——————————————————————"
 }
 
 
 #############
 #	vmess设置	#
#############

DynamicPort(){
  read -p "是否启用动态端口?（默认开启） [y/n]:" ifdynamicport 
 [ -z "$ifdynamicport" ] && ifdynamicport='y' 
 if [[ $ifdynamicport == 'y' ]];then 
  
 read -p "输入数据端口起点（默认：32001）:" port1 
 [ -z "$port1" ] && port1=32000 
  
 read -p "输入数据端口终点（默认：32500）:" port2 
 [ -z "$port2" ] && port2=32500 
  
 read -p "输入每次开放端口数（默认：10）:" port_num 
 [ -z "$port_num" ] && port_num=10 
  
 read -p "输入端口变更时间（单位：分钟）:" refresh 
 [ -z "$refresh" ] && refresh=5 
 
 echo "	——————————————————————
	动态端口配置：
	端口范围：${port1}-${port2}
	开放端口：${port_num}
	刷新时间：${refresh}
	——————————————————————"

 movePort="
\"inboundDetour\":[
    {
      \"protocol\": \"vmess\",
      \"port\": \"${port1}-${port2}\",
      \"tag\": \"dynamicPort\",       
      \"settings\": {
        \"default\": {
          \"level\": 1,
          \"alterId\": 64
        }
      },
      \"allocate\": {
        \"strategy\": \"random\",
        \"concurrency\":${port_num},
        \"refresh\": ${refresh}
      }
    }
  ],"
detour=',
      "detour": {        
        "to": "dynamicPort"   
      }'
 else 
 movePort='' 
 detour=''
  echo "	——————————————————————
	动态端口配置：
							
								不开启
								
								
	——————————————————————"

 fi 
 }
 
 ##################
 #	Shadowsocks设置	#
 ##################

Set_method(){
 echo "选择加密方法
1.aes-256-cfb(默认)
2.aes-128-cfb
3.chacha20
4.chacha20-ietf
5.aes-256-gcm
6.aes-128-gcm
7.chacha20-poly1305
"
read setm
[[ -z ${setm} ]] && setm='1'
if [[ ${setm} == '1' ]]; then
	method='aes-256-cfb'
elif [[ ${setm} == '2' ]]; then
	method='aes-128-cfb'
elif [[ ${setm} == '3' ]]; then
	method='chacha20'
elif [[ ${setm} == '4' ]]; then 
	method='chacha20-ietf'
elif [[ ${setm} == '5' ]]; then
	method='aes-256-gcm'
elif [[ ${setm} == '6' ]]; then
	method='aes-128-gcm'
elif [[ ${setm} == '7' ]]; then
	method='chacha20-poly1305'
else
	echo "请输入正确选项!" 
	Set_method
fi
echo "	——————————————————————
	加密：${method}
	——————————————————————"
}

#############
#	socks设置	#
############

Set_auth(){
 echo "请选择socks协议验证方式
1.匿名
2.用户密码
" 
read cauth
if [[ ${cauth} == '1' ]]; then
	auth='none'
	authconf="  			\"auth\": \"none\",
  			\"accounts\": [
    			{
      				\"user\": \"\",
      				\"pass\": \"\"
    			}
  			],
  		\"udp\": false,
 		 \"ip\": \"127.0.0.1\",
  		\"timeout\": 0,
 		 \"userLevel\": 0
		}"
elif [[ ${cauth} == '2' ]]; then
	auth='password'
	echo "输入用户名"
	read username
	Set_passwd
	 echo "	——————————————————————
	Socks配置：
	认证方式：${auth}
	用户名：${username}
	密码：${pw}
	——————————————————————"
	authconf="		\"auth\": \"password\",
  			\"accounts\": [
    			{
      				\"user\": \"${username}\",
      				\"pass\": \"${uuid}\"
    			}
  			],
  		\"udp\": false,
 		 \"ip\": \"127.0.0.1\",
  		\"timeout\": 0,
 		 \"userLevel\": 0
		}
"
else
	echo -e "${Error} 输入错误，请重试~"
	Set_auth
fi
}

#############
#	客户端设置	#
 #############
 
 Max_Cool(){
  read -p "是否启用 Mux.Cool?（默认开启） [y/n]:" ifmux 
 [ -z "$ifmux" ] && ifmux='y' 
 if [[ $ifmux == 'y' ]];then 
 mux=',
            "mux": {"enabled": true}
 ' 
 ifmux='true'
 echo "	——————————————————————
	Mux.Cool多路复用：开启
	——————————————————————"
 else 
 mux="" 
  echo "	——————————————————————
	Mux.Cool多路复用：不开启
	——————————————————————"
ifmux='false'
 fi 
 }
 
 Client_proxy(){
  while :; do echo 
 echo '1. HTTP代理（默认）' 
 echo '2. Socks代理' 
 read -p "请选择客户端代理类型: " chooseproxytype 
 [ -z "$chooseproxytype" ] && chooseproxytype=1 
 if [[ ! $chooseproxytype =~ ^[1-2]$ ]]; then 
 echo '输入错误，请输入正确的数字！' 
 else 
 break 
 fi 
 done 
  
 if [[ $chooseproxytype == 1 ]]; then 
 proxy='http' 
 else 
 proxy='socks' 
 fi 
  echo "	——————————————————————
	客户端代理类型：	${proxy}
	——————————————————————"
 }
 
 #########
 #	安装	#
 ########
 
 Install_v2ray(){
 bash <(curl -L -s https://install.direct/go.sh)
 Stop
 }
 
 Install_Shadowsocks(){
 
 }
 
 Install_vmess(){
 
 }
 
 Install_socks(){

 }
 
 Sh_config(){
echo "
{
	\"loglv\":\"${loglv}\",
	\"type\":\"${ctype}\",
	\"ip\":\"${ip}\",
	\"port\":\"${port}\",
	\"move\":\"${port1}～${port2}\",
	\"portNum\":\"${port_num}\",
	\"refresh\":\"${refresh}\",
	\"mux\":\"${ifmux}\",
	\"proxy\":\"${proxy}\",
	\"user\":\"${username}\",
	\"method\":\"${method}\",
	\"auth\":\"${auth}\",
	\"uuid\":\"${uuid}\"
}" > /etc/v2ray/sh_config.json
}

 View_config(){
loglv=$( cat /etc/v2ray/sh_config.json | jq -r '.loglv' )
portNum=$( cat /etc/v2ray/sh_config.json | jq -r '.portNum' )
refresh=$( cat /etc/v2ray/sh_config.json | jq -r '.refresh' )
shtype=$( cat /etc/v2ray/sh_config.json | jq -r '.type' )
ip=$( cat /etc/v2ray/sh_config.json | jq -r '.ip' )
port=$( cat /etc/v2ray/sh_config.json | jq -r '.port' )
move=$( cat /etc/v2ray/sh_config.json | jq -r '.move' )
proxy=$( cat /etc/v2ray/sh_config.json | jq -r '.proxy' )
user=$( cat /etc/v2ray/sh_config.json | jq -r '.user' )
method=$( cat /etc/v2ray/sh_config.json | jq -r '.method' )
auth=$( cat /etc/v2ray/sh_config.json | jq -r '.auth' )
uuid=$( cat /etc/v2ray/sh_config.json | jq -r '.uuid' )
ifmux=$( cat /etc/v2ray/sh_config.json | jq -r '.mux' )
 if [[ ${shtype} == '2' ]]; then
 	echo -e "	——————————————————————
	V2ray配置
	————————
	服务模式：Vmess
	————————
	IP地址：${ip}
	端口：${port}
	UUID：${uuid}
	alterId：${alterld}
	动态端口：
		范围：	${move}
		刷新频率：	${refresh}	分钟
		同时开放	${Green_font_prefix}${portNum}${Font_color_suffix}	端口
	Mux.Cool多路复用：${Green_font_prefix}${ifmux}${Font_color_suffix}
	客户端加密：auto
	用户配置路径：/etc/v2ray/user_config.json
	——————————————————————"
elif [[ ${shtype} == '1' ]]; then
	echo -e "	——————————————————————
	V2ray配置
	————————
	服务模式：Shadowsocks
	————————
	IP地址：${ip}
	端口：${port}
	加密方式：${method}
	密码：${uuid}
	——————————————————————"
	else
	echo -e "	——————————————————————
	V2ray配置
	————————
	服务模式：Socks
	————————
	IP地址：${ip}
	端口：${port}
	认证方式：${auth}
	用户名：${user}
	密码：${uuid}
	——————————————————————"
	fi
 }
 
 Uninstall(){
 echo -e "${Info}确定要卸载？(y/n)默认n"
 read yn
 if [[ ${yn} == 'y' ]]; then
 systemctl stop v2ray
systemctl disable v2ray
Stop
update-rc.d -f v2ray remove
echo -e "${Info}正在删除配置文件"
rm -rf /etc/v2ray/*
echo -e "${Info}正在删除主程序"
rm -rf /usr/bin/v2ray/*
echo -e "${Info}正在删除日志"
rm -rf /var/log/v2ray/*
echo -e "${Info}正在删除服务配置"
rm -rf /lib/systemd/system/v2ray.service
rm -rf /etc/init.d/v2ray
echo -e "${Info}卸载完成~"
	else
	echo "已取消..."
	exit 0
fi
}
 
 #########
 #	配置	#
 ########
 
 Save_socks(){
 Stop
  echo -e "${Info}正在保存配置~"
 echo "{
	\"log\":{
    	\"loglevel\": \"${loglv}\",
    	\"access\": \"/var/log/v2ray/access.log\",
    	\"error\": \"/var/log/v2ray/error.log\"
  	},
  	\"inbound\": {
		\"port\": ${port},
		\"protocol\":\"socks\",
		\"settings\":{
${authconf}
  },
    \"outbound\": {
    \"protocol\": \"freedom\",
    \"settings\": {}
  }
}
" > /etc/v2ray/config.json
echo -e "${Info} 配置完成"
Start
 }
 
 
 Set_config_Shadowsocks(){
 Stop
 echo -e "${Info}正在保存配置~"
 echo "
{
  \"inbound\": {
    \"port\": ${port},
    \"protocol\": \"shadowsocks\",
    \"settings\": {
      \"method\": \"${method}\",
      \"ota\": true,
      \"password\": \"${uuid}\"
    }
  },
  \"outbound\": {
    \"protocol\": \"freedom\",  
    \"settings\": {}
  }
}
" > /etc/v2ray/config.json
echo -e "${Info}配置完成"
Start
}
 
Save_config(){
Stop
echo -e "${Info}保存配置~"
echo "{
  \"log\":{
    \"loglevel\": \"${loglv}\",
    \"access\": \"/var/log/v2ray/access.log\",
    \"error\": \"/var/log/v2ray/error.log\"
  },
  \"inbound\": {
    \"port\": ${port},
    \"protocol\": \"vmess\",    
    \"settings\": {
      \"clients\": [
        {
          \"id\": \"${uuid}\",
          \"alterId\": ${alterld}
        }
      ]${detour}
    }
  },
${movePort}
  \"outbound\": {
    \"protocol\": \"freedom\",
    \"settings\": {}
  }
}" > /etc/v2ray/config.json
echo -e "${Info}配置完成"
Start
}

User_config(){
echo -e "${Info}保存配置~"
echo "
{
  \"log\":{
    \"loglevel\": \"none\",
    \"access\": \"\",
    \"error\": \"\"
  },
  \"inbound\": {
    \"port\": 1080,
    \"protocol\": \"${proxy}\",
    \"settings\": {
      \"auth\": \"noauth\",
      \"udp\": ${tfudp}
    }
  },
  \"outbound\": {
    \"protocol\": \"vmess\",
    \"settings\": {
      \"vnext\": [
        {
          \"address\": \"${ip}\",
          \"port\": ${port},  
          \"users\": [
            {
              \"id\": \"${uuid}\",
              \"alterId\": ${alterld},
              \"security\": \"auto\"
            }
          ]
        }
      ]
    }
  },
  \"outboundDetour\": [
    {
      \"protocol\": \"freedom\",
      \"settings\": {},
      \"tag\": \"direct\"
    }
  ],
  \"routing\": {
    \"strategy\": \"rules\",
    \"settings\": {
      \"domainStrategy\": \"IPIfNonMatch\",
      \"rules\": [
        {
          \"type\": \"chinasites\",
          \"outboundTag\": \"direct\"
        },
        {
          \"type\": \"chinaip\",
          \"outboundTag\": \"direct\"
        }
      ]
    }
  }
}
" > /etc/v2ray/user_config.json
echo -e "${Tip} 客户端配置已生成~"
echo "路径：/etc/v2ray/user_config.json"
}

User_Shadowsocks(){
Stop
echo "
{
  \"inbound\": {
    \"port\": 1080,
    \"protocol\": \"socks\",
    \"settings\": {
      \"auth\": \"noauth\"
    }
  },
  \"outbound\":{
    \"protocol\": \"shadowsocks\",
    \"settings\": {
      \"servers\": [
        {
          \"address\": \"${ip}\", 
          \"method\": \"${method}\",
          \"ota\": ${otatf},
          \"password\": \"${uuid}\",
          \"port\": ${port}
        }
      ]
    }
  }
}
" > /etc/v2ray/user_config.json
echo -e "${Info} 完成~"
}



Update_shell
clear
echo  -e "v2ray安装/管理脚本 [v${Green_font_prefix}${sh_ver}${Font_color_suffix}]
———— Author:johnpoint ————

  ${Green_font_prefix}1.${Font_color_suffix} 安装 v2ray
  ${Green_font_prefix}2.${Font_color_suffix} 卸载 v2ray
  ——————————————————————
  ${Green_font_prefix}3.${Font_color_suffix} 修改 v2ray 用户设置
  ${Green_font_prefix}4.${Font_color_suffix} 修改 v2ray 服务端设置
  ${Green_font_prefix}5.${Font_color_suffix} 查看 v2ray 用户设置
  ——————————————————————
  ${Green_font_prefix}6.${Font_color_suffix} 启动 v2ray 
  ${Green_font_prefix}7.${Font_color_suffix} 停止 v2ray 
  ${Green_font_prefix}8.${Font_color_suffix} 重启 v2ray 
  ${Green_font_prefix}9.${Font_color_suffix} 查看 v2ray 状态
  ——————————————————————
  ${Green_font_prefix}10.${Font_color_suffix} 切换 基础版
  ——————————————————————
  ${Green_font_prefix}00.${Font_color_suffix} 更新 主程序
  ${Green_font_prefix}0.${Font_color_suffix} 更新 脚本
"
read mainset
if [[ ${mainset} == '1' ]]; then
	Set_type
elif [[ ${mainset} == '2' ]]; then
	Uninstall
elif [[ ${mainset} == '3' ]]; then
	Cg_user
elif [[ ${mainset} == '4' ]]; then
	Cg_service
elif [[ ${mainset} == '5' ]]; then
	View_config
elif [[ ${mainset} == '6' ]]; then
	Start
elif [[ ${mainset} == '7' ]]; then
	Stop
elif [[ ${mainset} == '8' ]]; then
	Restart
elif [[ ${mainset} == '9' ]]; then
	Status
elif [[ ${mainset} == '10' ]]; then
	To_base
elif [[ ${mainset} == '0' ]]; then
	Update_shell
elif [[ ${mainset} == '00' ]]; then
	Install_main
else
	echo "输入不正确!"
	exit 0
fi
