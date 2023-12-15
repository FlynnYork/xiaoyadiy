if [ -d $PWD/docker/xiaoya/mytoken.txt ]; then
	rm -rf $PWD/docker/xiaoya/mytoken.txt
fi
mkdir -p $PWD/docker/xiaoya
touch $PWD/docker/xiaoya/mytoken.txt
touch $PWD/docker/xiaoya/myopentoken.txt
touch $PWD/docker/xiaoya/temp_transfer_folder_id.txt

mytokenfilesize=$(cat $PWD/docker/xiaoya/mytoken.txt)
mytokenstringsize=${#mytokenfilesize}
if [ $mytokenstringsize -le 31 ]; then
	echo -e "\033[32m"
	read -p "输入你的阿里云盘 Token（32位长）: " token
	token_len=${#token}
	if [ $token_len -ne 32 ]; then
		echo "长度不对,阿里云盘 Token是32位长"
		echo -e "安装停止，请参考指南配置文件\nhttps://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f \n"
		echo -e "\033[0m"
		exit
	else	
		echo $token > $PWD/docker/xiaoya/mytoken.txt
	fi
	echo -e "\033[0m"
fi	

myopentokenfilesize=$(cat $PWD/docker/xiaoya/myopentoken.txt)
myopentokenstringsize=${#myopentokenfilesize}
if [ $myopentokenstringsize -le 279 ]; then
	echo -e "\033[33m"
        read -p "输入你的阿里云盘 Open Token（280位长或者335位长）: " opentoken
	opentoken_len=${#opentoken}
        if [[ $opentoken_len -ne 280 ]] && [[ $opentoken_len -ne 335 ]]; then
                echo "长度不对,阿里云盘 Open Token是280位长或者335位"
		echo -e "安装停止，请参考指南配置文件\nhttps://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f \n"
		echo -e "\033[0m"
                exit
        else
        	echo $opentoken > $PWD/docker/xiaoya/myopentoken.txt
	fi
	echo -e "\033[0m"
fi

folderidfilesize=$(cat $PWD/docker/xiaoya/temp_transfer_folder_id.txt)
folderidstringsize=${#folderidfilesize}
if [ $folderidstringsize -le 39 ]; then
	echo -e "\033[36m"
        read -p "输入你的阿里云盘转存目录folder id: " folderid
	folder_id_len=${#folderid}
	if [ $folder_id_len -ne 40 ]; then
                echo "长度不对,阿里云盘 folder id是40位长"
		echo -e "安装停止，请参考指南配置文件\nhttps://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f \n"
		echo -e "\033[0m"
                exit
        else
        	echo $folderid > $PWD/docker/xiaoya/temp_transfer_folder_id.txt
	fi	
	echo -e "\033[0m"
fi

#echo "new" > $PWD/docker/xiaoya/show_my_ali.txt
if command -v ifconfig &> /dev/null; then
        localip=$(ifconfig -a|grep inet|grep -v 172.17 | grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"|head -n1)
else
        localip=$(ip address|grep inet|grep -v 172.17 | grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"|head -n1|cut -f1 -d"/")
fi

if [ $1 ]; then
if [ $1 == 'host' ]; then
	if [ ! -s $PWD/docker/xiaoya/docker_address.txt ]; then
		echo "http://$localip:6789" > $PWD/docker/xiaoya/docker_address.txt
	fi	
	docker stop xiaoya-hostmode
	docker rm xiaoya-hostmode
	docker rmi xiaoyaliu/alist:hostmode
	docker pull xiaoyaliu/alist:hostmode
	if [[ -f $PWD/docker/xiaoya/proxy.txt ]] && [[ -s $PWD/docker/xiaoya/proxy.txt ]]; then
        	proxy_url=$(head -n1 $PWD/docker/xiaoya/proxy.txt)
		docker run -d --env HTTP_PROXY="$proxy_url" --env HTTPS_PROXY="$proxy_url" --env no_proxy="*.aliyundrive.com" --network=host -v $PWD/docker/xiaoya:/data --restart=always --name=xiaoya-hostmode xiaoyaliu/alist:hostmode
	else	
		docker run -d --network=host -v $PWD/docker/xiaoya:/data --restart=always --name=xiaoya-hostmode xiaoyaliu/alist:hostmode
	fi	
	exit
fi
fi

if [ ! -s $PWD/docker/xiaoya/docker_address.txt ]; then
        echo "http://$localip:5678" > $PWD/docker/xiaoya/docker_address.txt
fi
docker stop xiaoya
docker rm xiaoya
docker rmi xiaoyaliu/alist:latest 
docker pull xiaoyaliu/alist:latest
if [[ -f $PWD/docker/xiaoya/proxy.txt ]] && [[ -s $PWD/docker/xiaoya/proxy.txt ]]; then
	proxy_url=$(head -n1 $PWD/docker/xiaoya/proxy.txt)
       	docker run -d -p 5678:80 -p 2345:2345 -p 2346:2346 --env HTTP_PROXY="$proxy_url" --env HTTPS_PROXY="$proxy_url" --env no_proxy="*.aliyundrive.com" -v $PWD/docker/xiaoya:/data --restart=always --name=xiaoya xiaoyaliu/alist:latest
else
	docker run -d -p 5678:80 -p 2345:2345 -p 2346:2346 -v $PWD/docker/xiaoya:/data --restart=always --name=xiaoya xiaoyaliu/alist:latest
fi	

