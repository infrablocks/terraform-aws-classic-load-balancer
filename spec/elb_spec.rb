require 'spec_helper'

describe 'ELB' do
  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:name) { output_for(:harness, 'name') }

  subject { elb(name) }

  it { should exist }
  its(:subnets) { should contain_exactly(*output_for(:prerequisites, 'subnet_ids')) }
  its(:scheme) { should eq('internal') }

  its(:health_check_target) { should eq(vars.health_check_target) }
  its(:health_check_timeout) { should eq(vars.health_check_timeout.to_i) }
  its(:health_check_interval) { should eq(vars.health_check_interval.to_i) }
  its(:health_check_unhealthy_threshold) { should eq(vars.health_check_unhealthy_threshold.to_i) }
  its(:health_check_healthy_threshold) { should eq(vars.health_check_healthy_threshold.to_i) }

  it { should have_listener(
      protocol: configuration.for(:harness).listener_1_lb_protocol,
      port: configuration.for(:harness).listener_1_lb_port.to_i,
      instance_protocol: configuration.for(:harness).listener_1_instance_protocol,
      instance_port: configuration.for(:harness).listener_1_instance_port.to_i) }
  it { should have_listener(
      protocol: configuration.for(:harness).listener_2_lb_protocol,
      port: configuration.for(:harness).listener_2_lb_port.to_i,
      instance_protocol: configuration.for(:harness).listener_2_instance_protocol,
      instance_port: configuration.for(:harness).listener_2_instance_port.to_i) }

  it 'outputs the zone ID' do
    expect(output_for(:harness, 'zone_id'))
        .to(eq(subject.canonical_hosted_zone_name_id))
  end

  it 'outputs the DNS name' do
    expect(output_for(:harness, 'dns_name'))
        .to(eq(subject.dns_name))
  end

  it 'is associated with the load balancer security group' do
    expect(subject)
        .to(have_security_group("elb-#{component}-#{deployment_identifier}"))
  end

  context 'tags' do
    subject do
      elb_client
          .describe_tags(load_balancer_names: [name])
          .tag_descriptions[0]
          .tags
          .map(&:to_h)
    end

    it { should include({key: 'Name',
        value: "elb-#{component}-#{deployment_identifier}"}) }
    it { should include({key: 'Component', value: component}) }
    it { should include({key: 'DeploymentIdentifier',
        value: deployment_identifier}) }
  end

  context 'attributes' do
    subject do
      elb_client
          .describe_load_balancer_attributes(load_balancer_name: name)
          .load_balancer_attributes
    end

    let(:cross_zone_enabled) { vars.enable_cross_zone_load_balancing == 'yes' }
    let(:connection_draining_enabled) { vars.enable_connection_draining == 'yes' }

    it 'uses the provided flag for cross zone load balancing' do
      cross_zone_attribute = subject.cross_zone_load_balancing.to_h

      expect(cross_zone_attribute).to eq({enabled: cross_zone_enabled})
    end

    it 'uses the provided flag and timeout for connection draining' do
      connection_draining_attribute = subject.connection_draining

      expect(connection_draining_attribute.enabled)
          .to(eq(connection_draining_enabled))
      expect(connection_draining_attribute.timeout)
          .to(eq(vars.connection_draining_timeout.to_i))
    end

    it 'uses the provided idle timeout' do
      connection_settings_attribute = subject.connection_settings

      expect(connection_settings_attribute.idle_timeout)
          .to(eq(vars.idle_timeout.to_i))
    end
  end

  context 'when ELB is exposed to the public internet' do
    before(:all) do
      reprovision(expose_to_public_internet: 'yes')
    end

    its(:scheme) { should eq('internet-facing') }
  end

  context 'when ELB is not exposed to the public internet' do
    before(:all) do
      reprovision(expose_to_public_internet: 'no')
    end

    its(:scheme) { should eq('internal') }
  end
end