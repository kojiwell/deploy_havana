DIR=./demoCA
SUBJECT="/C=US/ST=ANYSTATE/L=ANYCITY/O=OPENSTACK/CN=www.openstack.local"
PASSWORD="ANYTHING"
DAYS=3650
mkdir -p $DIR
mkdir -p $DIR/certs
mkdir -p $DIR/crl
mkdir -p $DIR/newcerts
mkdir -p $DIR/private
touch $DIR/index.txt
openssl req -new -keyout $DIR/private/./cakey.pem -out $DIR/./careq.pem -days $DAYS -passout pass:$PASSWORD -subj $SUBJECT
openssl ca -create_serial -passin pass:$PASSWORD -out $DIR/./cacert.pem -days $DAYS -batch -keyfile $DIR/private/./cakey.pem -selfsign -extensions v3_ca -subj $SUBJECT -infiles $DIR/./careq.pem
openssl genrsa -passout pass:$PASSWORD -des3 -out demoCA/private/server.key 1024 -subj $SUBJECT
openssl req -passin pass:$PASSWORD -new -days $DAYS -key demoCA/private/server.key -out demoCA/certs/server.csr -subj $SUBJECT
openssl ca -passin pass:$PASSWORD -in demoCA/certs/server.csr -batch -keyfile demoCA/private/cakey.pem -out demoCA/certs/server.crt -policy policy_anything -days $DAYS
