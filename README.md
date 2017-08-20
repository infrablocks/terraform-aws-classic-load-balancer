Terraform AWS Encrypted Bucket
==============================

[![CircleCI](https://circleci.com/gh/infrablocks/terraform-aws-encrypted-bucket.svg?style=svg)](https://circleci.com/gh/infrablocks/terraform-aws-encrypted-bucket)

A Terraform module for building an encrypted bucket in AWS S3.

Usage
-----

To use the module, include something like the following in your terraform configuration:

```hcl-terraform
module "encrypted_bucket" {
  source = "git@github.com:infrablocks/terraform-aws-encrypted-bucket.git//src"
  
  region = "eu-west-2"
  bucket_name = "my-organisations-encrypted-bucket"
}
```

Executing `terraform get` will fetch the module.


### Inputs

| Name                        | Description                                 | Default | Required |
|-----------------------------|---------------------------------------------|:-------:|:--------:|
| region                      | The region into which to deploy the VPC     | -       | yes      |
| bucket_name                 | The name to use for the encrypted S3 bucket | -       | yes      |


### Outputs

| Name                         | Description                                           |
|------------------------------|-------------------------------------------------------|


Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed on your
development machine:

* Ruby (2.3.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv

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
rbenv install 2.3.1
rbenv rehash
rbenv local 2.3.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

To provision module infrastructure, run tests and then destroy that infrastructure,
execute:

```bash
./go
```

To provision the module contents:

```bash
./go provision[<deployment_identifier>]
```

To destroy the module contents:

```bash
./go destroy[<deployment_identifier>]
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at https://github.com/infrablocks/terraform-aws-encrypted-bucket. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


License
-------

The library is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
