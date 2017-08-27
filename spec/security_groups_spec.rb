require 'spec_helper'

describe 'Security Groups' do
  let(:component) {vars.component}
  let(:deployment_identifier) {vars.deployment_identifier}

  context 'for ELB' do
    subject {security_group("elb-#{component}-#{deployment_identifier}")}

    it { should exist }
    its(:vpc_id) {should eq(output_with_name('vpc_id'))}
  end
end
