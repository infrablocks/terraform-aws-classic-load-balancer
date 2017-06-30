require 'bundler/setup'
require 'awspec'
require 'support/shared_contexts/terraform'
require 'securerandom'

require_relative '../lib/terraform'

RSpec.configure do |config|
  repository_name = ENV['REPOSITORY_NAME']

  config.example_status_persistence_file_path = '.rspec_status'

  config.add_setting :region, default: 'eu-west-2'
  config.add_setting :repository_name,
                     default: repository_name || SecureRandom.hex[0, 8]

  config.before(:suite) do
    variables = RSpec.configuration
    configuration_directory = Paths.from_project_root_directory('src')

    puts
    puts "Provisioning for repository name: #{variables.repository_name}"
    puts

    Terraform.clean
    Terraform.apply(
        directory: configuration_directory,
        vars: {
            region: variables.region,
            repository_name: variables.repository_name
        })

    puts
  end

  config.after(:suite) do
    unless repository_name
      variables = RSpec.configuration
      configuration_directory = Paths.from_project_root_directory('src')

      puts
      puts "Destroying for repository name: #{variables.repository_name}"
      puts

      Terraform.clean
      Terraform.destroy(
          directory: configuration_directory,
          force: true,
          vars: {
              region: variables.region,
              repository_name: variables.repository_name
          })

      puts
    end
  end
end