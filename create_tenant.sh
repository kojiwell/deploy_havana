
if [[ $1 == "" ]]; then
    echo "
    usage:
       
       bash create_tenant.sh <tenant name>

    "
    exit 1
fi

keystone tenant-create --name $1 --enabled true
