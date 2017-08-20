require 'securerandom'

require_relative 'paths'
require_relative 'vars'

class Configuration
  def state_file
    Paths.from_project_root_directory('terraform.tfstate')
  end

  def source_directory
    'spec/infra'
  end

  def work_directory
    'build'
  end

  def configuration_directory
    File.join(work_directory, source_directory)
  end

  def deployment_identifier
    ENV['DEPLOYMENT_IDENTIFIER'] ||
        SecureRandom.hex[0, 8]
  end

  def vars_template_file
    ENV['VARS_TEMPLATE_FILE'] ||
        Paths.from_project_root_directory('config/vars/default.yml.erb')
  end

  def vars
    @vars ||= Vars.load_from(vars_template_file, {
        project_directory: Paths.project_root_directory,
        deployment_identifier: deployment_identifier
    })
  end
end