Terraform AWS Classic Load Balancer
===================================

[![CircleCI](https://circleci.com/gh/infrablocks/terraform-aws-classic-load-balancer.svg?style=svg)](https://circleci.com/gh/infrablocks/terraform-aws-classic-load-balancer)

A Terraform module for building a classic load balancer in AWS.

The load balancer requires:
* An existing VPC
* Some existing subnets
* A domain name and public and private hosted zones
 
The ECS load balancer consists of:
* An ELB
  * Deployed across the provided subnet IDs
  * Either internal or internet-facing as specified
  * With listeners for each of the supplied listener configurations
  * With a health check using the specified target
  * With connection draining as specified
* A security group allowing access to/from the load balancer according to the 
  specified access control and egress CIDRs configuration
* A security group for use by instances allowing access from the load balancer
  according to the specified access control configuration
* A DNS entry
  * In the public hosted zone if specified
  * In the private hosted zone if specified

![Diagram of infrastructure managed by this module](https://raw.githubusercontent.com/infrablocks/terraform-aws-classic-load-balancer/main/docs/architecture.png)

Usage
-----

To use the module, include something like the following in your Terraform
configuration:

```hcl-terraform
module "classic_load_balancer" {
  source  = "infrablocks/classic-load-balancer/aws"
  version = "0.1.7"

  region = "eu-west-2"
  vpc_id = "vpc-fb7dc365"
  subnet_ids = "subnet-ae4533c4,subnet-443e6b12"
  
  component = "important-component"
  deployment_identifier = "production"
  
  domain_name = "example.com"
  public_zone_id = "Z1WA3EVJBXSQ2V"
  private_zone_id = "Z3CVA9QD5NHSW3"
  
  listeners = [
    {
      lb_port = 443
      lb_protocol = "HTTPS"
      instance_port = 443
      instance_protocol = "HTTPS"
      ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/default"
    },
    {
      lb_port = 6567
      lb_protocol = "TCP"
      instance_port = 6567
      instance_protocol = "TCP"
    }
  ]
  
  access_control = [
    {
      lb_port = 443
      instance_port = 443
      allow_cidr = '0.0.0.0/0'
    },
    {
      lb_port = 6567
      instance_port = 6567
      allow_cidr = '10.0.0.0/8'
    }
  ]
  
  egress_cidrs = '10.0.0.0/8'
  
  health_check_target = 'HTTPS:443/ping'
  health_check_timeout = 10
  health_check_interval = 30
  health_check_unhealthy_threshold = 5
  health_check_healthy_threshold = 5

  enable_cross_zone_load_balancing = 'yes'

  enable_connection_draining = 'yes'
  connection_draining_timeout = 60

  idle_timeout = 60

  include_public_dns_record = 'yes'
  include_private_dns_record = 'yes'

  expose_to_public_internet = 'yes'
}
```

As mentioned above, the load balancer deploys into an existing base network. 
Whilst the base network can be created using any mechanism you like, the 
[AWS Base Networking](https://github.com/infrablocks/terraform-aws-base-networking)
module will create everything you need. See the 
[docs](https://github.com/infrablocks/terraform-aws-base-networking/blob/main/README.md)
for usage instructions.

See the 
[Terraform registry entry](https://registry.terraform.io/modules/infrablocks/classic-load-balancer/aws/latest) 
for more details.

### Inputs

| Name                             | Description                                                                   | Default             | Required                             |
|----------------------------------|-------------------------------------------------------------------------------|:-------------------:|:------------------------------------:|
| region                           | The region into which to deploy the load balancer                             | -                   | yes                                  |
| vpc_id                           | The ID of the VPC into which to deploy the load balancer                      | -                   | yes                                  |
| subnet_ids                       | The IDs of the subnets for the ELB                                            | -                   | yes                                  |
| component                        | The component for which the load balancer is being created                    | -                   | yes                                  |
| deployment_identifier            | An identifier for this instantiation                                          | -                   | yes                                  |
| domain_name                      | The domain name of the supplied Route 53 zones                                | -                   | yes                                  |
| public_zone_id                   | The ID of the public Route 53 zone                                            | -                   | if include_public_dns_record is yes  |
| private_zone_id                  | The ID of the private Route 53 zone                                           | -                   | if include_private_dns_record is yes |
| listeners                        | A list of listener configurations for the ELB                                 | -                   | yes                                  |
| access_control                   | A list of access control configurations for the security groups               | -                   | yes                                  |
| egress_cidrs                     | The CIDRs that the load balancer is allowed to access                         | The CIDR of the VPC | no                                   |
| health_check_target              | The target to use for health checks                                           | TCP:80              | yes                                  |
| health_check_timeout             | The time after which a health check is considered failed in seconds           | 5                   | yes                                  |
| health_check_interval            | The time between health check attempts in seconds                             | 30                  | yes                                  |
| health_check_unhealthy_threshold | The number of failed health checks before an instance is taken out of service | 2                   | yes                                  |
| health_check_healthy_threshold   | The number of successful health checks before an instance is put into service | 10                  | yes                                  |
| enable_cross_zone_load_balancing | Whether or not to enable cross zone load balancing ("yes" or "no")            | yes                 | yes                                  |
| enable_connection_draining       | Whether or not to enable connection draining ("yes" or "no")                  | no                  | yes                                  |
| connection_draining_timeout      | The time after which connection draining is aborted in seconds                | 300                 | yes                                  |
| idle_timeout                     | The time after which idle connections are closed                              | 60                  | yes                                  |
| include_public_dns_record        | Whether or not to create a public DNS entry ("yes" or "no")                   | no                  | yes                                  |
| include_private_dns_record       | Whether or not to create a private DNS entry ("yes" or "no")                  | yes                 | yes                                  |
| expose_to_public_internet        | Whether or not to the ELB should be internet facing ("yes" or "no")           | no                  | yes                                  |

### Outputs

| Name                                    | Description                                               |
|-----------------------------------------|-----------------------------------------------------------|
| name                                    | The name of the created ELB                               |
| zone_id                                 | The zone ID of the created ELB                            |
| dns_name                                | The DNS name of the created ELB                           |
| address                                 | The address of the DNS record(s) for the created ELB      |
| security_group_id                       | The ID of the ELB security group                          |
| open_to_load_balancer_security_group_id | The ID of the security group allowing access from the ELB |

### Compatibility

This module is compatible with Terraform versions greater than or equal to 
Terraform 1.0.

Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed 
on your development machine:

* Ruby (3.1.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv
* aws-vault

#### Mac OS X Setup

Installing the required tools is best managed by [homebrew](http://brew.sh).

To install homebrew:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, to install the required tools:

```
# ruby
brew install rbenv
brew install ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
eval "$(rbenv init -)"
rbenv install 3.1.1
rbenv rehash
rbenv local 3.1.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# aws-vault
brew cask install

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

Running the build requires an AWS account and AWS credentials. You are free to 
configure credentials however you like as long as an access key ID and secret
access key are available. These instructions utilise 
[aws-vault](https://github.com/99designs/aws-vault) which makes credential
management easy and secure.

To provision module infrastructure, run tests and then destroy that 
infrastructure, execute:

```bash
aws-vault exec <profile> -- ./go
```

To provision the module prerequisites:

```bash
aws-vault exec <profile> -- ./go deployment:prerequisites:provision[<deployment_identifier>]
```

To provision the module contents:

```bash
aws-vault exec <profile> -- ./go deployment:root:provision[<deployment_identifier>]
```

To destroy the module contents:

```bash
aws-vault exec <profile> -- ./go deployment:root:destroy[<deployment_identifier>]
```

To destroy the module prerequisites:

```bash
aws-vault exec <profile> -- ./go deployment:prerequisites:destroy[<deployment_identifier>]
```

Configuration parameters can be overridden via environment variables:

```bash
DEPLOYMENT_IDENTIFIER=testing aws-vault exec <profile> -- ./go
```

When a deployment identifier is provided via an environment variable, 
infrastructure will not be destroyed at the end of test execution. This can
be useful during development to avoid lengthy provision and destroy cycles.

By default, providers will be downloaded for each terraform execution. To
cache providers between calls:

```bash
TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache" aws-vault exec <profile> -- ./go
```

### Common Tasks

#### Generating an SSH key pair

To generate an SSH key pair:

```
ssh-keygen -m PEM -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

#### Generating a self-signed certificate

To generate a self signed certificate:
```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

To decrypt the resulting key:

```
openssl rsa -in key.pem -out ssl.key
```

#### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at
https://github.com/infrablocks/terraform-aws-application-load-balancer. 
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

License
-------

The library is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
