# AWS Client VPN from Oregon to Tokyo by Terraform


## Summary

* create VPC, subnet in tokyo and oregon
* create VPC peering between tokyo and oregon
* create client VPN endpoint in oregon
* connect instance in oregon from oregon client vpn
* connect instance in tokyo from oregon instance
* codes are based on https://blog.adachin.me/archives/9813


## Prerequisites

* Console > EC2 Dashboard > Key Pairs
  - create key pair for instance login
* Console > Certificate Manager
  - create ACM certificate for server
  - create ACM certificate for client

### commands to create certificate (details below)

```bash
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3/
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full server nopass
mkdir ./custom_folder
cp pki/ca.crt ./custom_folder
cp pki/issued/server.crt ./custom_folder
cp pki/private/server.key ./custom_folder
cd ./custom_folder
aws acm import-certificate --certificate file://server.crt --private-key file://server.key --certificate-chain file://ca.crt --region us-west-2
```


## Run

```bash
terraform apply
```

* check the output
  - `client_vpn_authorization_cvpn_vpc`
  - `client_vpn_authorization_main_vpc`
* VPC Dashboard > Client VPN Endpoints > Authorization
* click Authorize Ingress to add two cidr above
* VPC Dashboard > Client VPN Endpoints > Route Table
* click Create Route and add `client_vpn_authorization_main_vpc` cidr

### commands to create user (details below)

```bash
./easyrsa build-client-full client1 nopass
mkdir ./client_folder
cp pki/ca.crt ./client_folder
cp pki/issued/client1.crt ./client_folder
cp pki/private/client1.key ./client_folder
```

* click `Download Client Configuration` and save it to `client_folder`
* append two lines to the `downloaded-client-config.ovpn`
```
cert client1.crt
key client1.key
```

* drag and drop the config to Tunnelblick and Connect (see References)


## Result

* you should be able to ssh to `main_private_ip` in the output
* you should be able to ssh to `peer_private_ip` in the output
* from there, you should be able to ssh to `main_private_ip`


## create aws_acm_certificate details

```bash
OpenVPN$ git clone https://github.com/OpenVPN/easy-rsa.git
OpenVPN$ cd easy-rsa/easyrsa3/
easyrsa3[master=]$ ./easyrsa init-pki

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: ~/Documents/github/OpenVPN/easy-rsa/easyrsa3/pki
```

```
easyrsa3[master=]$ ./easyrsa build-ca nopass

Using SSL: openssl LibreSSL 2.6.5
Generating RSA private key, 2048 bit long modulus
..........................................+++
............+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:sample

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
~/Documents/github/OpenVPN/easy-rsa/easyrsa3/pki/ca.crt
```

```
easyrsa3[master=]$ ./easyrsa build-server-full server nopass

Using SSL: openssl LibreSSL 2.6.5
Generating a 2048 bit RSA private key
........................................+++
....................................+++
writing new private key to '~/Documents/github/OpenVPN/easy-rsa/easyrsa3/pki/private/server.key.TrZrC7IBcQ'
-----
Using configuration from ~/Documents/github/OpenVPN/easy-rsa/easyrsa3/pki/safessl-easyrsa.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until Jan 27 08:18:19 2022 GMT (1080 days)

Write out database with 1 new entries
Data Base Updated
```

```
easyrsa3[master=]$ ./easyrsa build-client-full client1 nopass

Using SSL: openssl LibreSSL 2.6.5
Generating a 2048 bit RSA private key
.....................................................................................................................................+++
...............................................................................................................+++
writing new private key to '~/Documents/github/OpenVPN/easy-rsa/easyrsa3/pki/private/client1.key.s0YFW8UUJm'
-----
Using configuration from ~/Documents/github/OpenVPN/easy-rsa/easyrsa3/pki/safessl-easyrsa.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'client1'
Certificate is to be certified until Jan 27 08:19:56 2022 GMT (1080 days)

Write out database with 1 new entries
Data Base Updated
```

```
easyrsa3[master=]$ mkdir ./custom_folder
easyrsa3[master=]$ cp pki/ca.crt ./custom_folder
easyrsa3[master %=]$ cp pki/issued/server.crt ./custom_folder
easyrsa3[master %=]$ cp pki/private/server.key ./custom_folder
easyrsa3[master %=]$ 
easyrsa3[master %=]$ cd custom_folder/
custom_folder[master %=]$ ls
ca.crt      server.crt  server.key
custom_folder[master %=]$ aws acm import-certificate --certificate file://server.crt --private-key file://server.key --certificate-chain file://ca.crt --region us-west-2
{
    "CertificateArn": "arn:aws:acm:us-west-2:242279356189:certificate/ad7c43df-76a3-41d8-88e6-27869903caf6"
}
```


## References

* https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html
* https://www.terraform.io/docs/providers/aws/r/ec2_client_vpn_endpoint.html
* https://www.terraform.io/docs/providers/aws/r/ec2_client_vpn_network_association.html
* https://qiita.com/atsumjp/items/837d8ea5763bb985ff8d
* https://inamuu.com/AWS Client VPNへ接続した際にインターネットへの接続を許/
* https://blog.adachin.me/archives/9813
