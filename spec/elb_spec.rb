require 'spec_helper'

describe 'ELB' do
  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:load_balancer_name) { output_with_name('elb_name') }

  subject { elb(load_balancer_name) }

  it { should exist }
end