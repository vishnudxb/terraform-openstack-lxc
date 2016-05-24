#terraform-openstack-lxc

Setup Openstack with LXC as hypervisor in AWS EC2 instance.

Here we are using [Terraform] (https://www.terraform.io/) inorder to do the Automation

#REQUIREMENTS
* Install Terraform
* You need to give the AWS ACCESS KEY, AWS SECRET KEY, KEY PAIR, KEY PAIR NAME and on AWS

#VARIABLES
* access_key = AWS Access Key
* secret_key = AWS Secret Key
* key_file   = AWS Private key file location in your laptop/system
* key_name   = AWS Key pair name
* ami        = AWS AMI ID

#HOW TO RUN THE COMMAND

```terraform apply -var 'access_key=<put your aws access key>' -var 'secret_key=<put your aws secret key>' -var 'key_file=<private key location>' -var 'ami=<ami of the instance>' -var 'key_name='
```

```
 terraform apply -var 'access_key=AXXXXXXXXXXXXX' -var 'secret_key=MYSECRETKEYXXXXXXXX' -var 'key_file=/User/privatekey.pem' -var 'ami=ami-fce3c696' -var 'key_name=openstack'

```

P.S: You can also create a var file and use the -var-file flag directly to specify a file
