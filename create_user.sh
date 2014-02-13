
if [[ $1 == "" || $2 == "" ]]; then
    echo "
    usage:
       
       bash create_user.sh <tenant> <user>

    "
    exit 1
fi

source setuprc

tenant=$1
username=$2
pass=$(tr -dc a-zA-Z0-9 </dev/urandom |  head -c 12)
cert_dir="~/$tenant"

keystone user-create --name $username --enabled true --pass $pass
keystone user-role-add --user $username --role "_member_" --tenant $tenant

test -d $cert_dir || mkdir $cert_dir
cat > $cert_dir/novarc-${tenant}-${username} <<EOF
export OS_USERNAME=$username
export OS_PASSWORD=$pass
export OS_TENANT_NAME=$tenant
export OS_AUTH_URL=http://${CONTROLLER_PUBLIC_ADDRESS}:5000/v2.0
EOF
