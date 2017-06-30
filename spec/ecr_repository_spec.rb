require 'spec_helper'

describe 'ECR Repository' do
  include_context :terraform

  let(:region) { RSpec.configuration.region }
  let(:repository_name) { RSpec.configuration.repository_name }

  subject { ecr_repository(repository_name) }

  it { should exist }

  it 'exposes the registry ID as an output' do
    expected_registry_id = subject.registry_id
    actual_registry_id = Terraform.output(name: 'registry_id')

    expect(actual_registry_id).to(eq(expected_registry_id))
  end

  it 'exposes the repository URL as an output' do
    expected_repository_url = subject.repository_uri
    actual_repository_url = Terraform.output(name: 'repository_url')

    expect(actual_repository_url).to(eq(expected_repository_url))
  end
end
