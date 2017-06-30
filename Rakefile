require 'rspec/core/rake_task'
require 'securerandom'
require 'git'
require 'semantic'

require_relative 'lib/terraform'

REPOSITORY_NAME = SecureRandom.hex[0, 8]

Terraform::Tasks.install('0.8.6')

task :default => 'test:integration'

namespace :test do
  RSpec::Core::RakeTask.new(:integration => ['terraform:ensure']) do
    ENV['AWS_REGION'] = 'eu-west-2'
  end
end

namespace :provision do
  desc 'Provisions module in AWS'
  task :aws, [:repository_name] => ['terraform:ensure'] do |_, args|
    repository_name = args.repository_name || REPOSITORY_NAME
    configuration_directory = Paths.from_project_root_directory('src')

    puts "Provisioning for repository name: #{repository_name}"

    Terraform.clean
    Terraform.apply(
        directory: configuration_directory,
        vars: terraform_vars_for(
            repository_name: repository_name))
  end
end

namespace :destroy do
  desc 'Destroys module in AWS'
  task :aws, [:repository_name] => ['terraform:ensure'] do |_, args|
    repository_name = args.repository_name || REPOSITORY_NAME
    configuration_directory = Paths.from_project_root_directory('src')

    puts "Destroying for repository name: #{repository_name}"

    Terraform.clean
    Terraform.destroy(
        directory: configuration_directory,
        force: true,
        vars: terraform_vars_for(
            repository_name: repository_name))
  end
end

namespace :release do
  desc 'Increment and push tag'
  task :tag do
    repo = Git.open('.')
    tags = repo.tags
    latest_tag = tags.map { |tag| Semantic::Version.new(tag.name) }.max
    next_tag = latest_tag.increment!(:patch)
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'master', tags: true)
  end
end

def terraform_vars_for(opts)
  {
      region: 'eu-west-2',
      repository_name: opts[:repository_name]
  }
end
