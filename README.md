Terraform AWS ECR Repository
============================

A Terraform module for building an ECR repository in AWS.

Usage
-----

To use the module, include something like the following in your terraform configuration:

```hcl-terraform
module "repository" {
  source = "git@github.com:tobyclemson/terraform-aws-ecr-repository.git//src"
  
  region = "eu-west-2"
  repository_name = "my-organisation/my-image"
}
```

Executing `terraform get` will fetch the module.


### Inputs

| Name                        | Description                                       | Default | Required |
|-----------------------------|---------------------------------------------------|:-------:|:--------:|
| region                      | The region into which to deploy the VPC           | -       | yes      |
| repository_name             | The repository name to use for the ECR repository | -       | yes      |


### Outputs

| Name                         | Description                                           |
|------------------------------|-------------------------------------------------------|
| registry_id                  | The account ID of the registry holfing the repository |
| repository_url               | The URL of the repository                             |


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
./go provision:aws[<deployment_identifier>]
```

To destroy the module contents:

```bash
./go destroy:aws[<deployment_identifier>]
```

### Common Tasks

To generate an SSH key pair:

```
ssh-keygen -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at https://github.com/tobyclemson/terraform-aws-base-networking. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


License
-------

The library is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
