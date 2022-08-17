line=$(docker ps | grep stor-gateway)
arr=($line)
echo "Connecting container $arr"
echo "Please enter user name (like so anand):"
read appluser
echo "Please enter password:"
read password
docker exec $arr /bin/sh -c "./adduser.sh $appluser $password"
echo "Users in your system:"
docker exec $arr pdbedit -L | awk -F: 'NF>=3'