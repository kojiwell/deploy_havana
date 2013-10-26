source setuprc

DIR=./demoCA
SUBJECT="/C=US/ST=ANYSTATE/L=ANYCITY/O=OPENSTACK/CN=www.openstack.local"
PASSWORD=${PASSWORD:-GoodForNothing}
DAYS=3650
TMPDIR=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c7)
mkdir /tmp/$TMPDIR
cd /tmp/$TMPDIR
mkdir -p $DIR
chmod 700 $DIR
mkdir -p $DIR/certs
mkdir -p $DIR/crl
mkdir -p $DIR/newcerts
mkdir -p $DIR/private
touch $DIR/index.txt
openssl req -new -keyout $DIR/private/cakey.pem -out $DIR/certs/careq.pem -days $DAYS -passout pass:$PASSWORD -subj $SUBJECT
openssl ca -create_serial -passin pass:$PASSWORD -out $DIR/certs/cacert.pem -days $DAYS -batch -keyfile $DIR/private/cakey.pem -selfsign -extensions v3_ca -subj $SUBJECT -infiles $DIR/certs/careq.pem
ln $DIR/certs/cacert.pem $DIR/cacert.pem
openssl genrsa -passout pass:$PASSWORD -des3 -out demoCA/private/ssl_key.pem 1024 -subj $SUBJECT
openssl req -passin pass:$PASSWORD -new -days $DAYS -key demoCA/private/ssl_key.pem -out demoCA/certs/ssl_csr.pem -subj $SUBJECT
openssl ca -passin pass:$PASSWORD -in demoCA/certs/ssl_csr.pem -batch -keyfile demoCA/private/cakey.pem -out demoCA/certs/ssl_cert.pem -policy policy_anything -days $DAYS
rm $DIR/cacert.pem
chmod 700 $DIR/private && chmod 600 $DIR/private/*
mv /tmp/$TMPDIR/$DIR $HOME/pki
cd
rm -rf /tmp/$TMPDIR
