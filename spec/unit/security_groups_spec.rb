# frozen_string_literal: true

require 'spec_helper'

describe 'security groups' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:vpc_id) do
    output(role: :prerequisites, name: 'vpc_id')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.listeners = [
          {
            lb_port: 80,
            lb_protocol: 'HTTP',
            instance_port: 8080,
            instance_protocol: 'HTTP',
            ssl_certificate_id: nil
          }
        ]
      end
    end

    it 'creates a security group for the load balancer' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'load_balancer')
              .once)
    end

    it 'uses a name constructed from the component and deployment ' \
       'identifier for the load balancer security group' do
      name = "elb-#{component}-#{deployment_identifier}"
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'load_balancer')
              .with_attribute_value(:name, name))
    end

    it 'includes the component in the description for the load ' \
       'balancer security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'load_balancer')
              .with_attribute_value(:description, match(/.*#{component}.*/)))
    end

    it 'includes the deployment identifier in the description for the load ' \
       'balancer security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'load_balancer')
              .with_attribute_value(
                :description, match(/.*#{deployment_identifier}.*/)
              ))
    end

    it 'uses the provided VPC ID on the load balancer security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'load_balancer')
              .with_attribute_value(:vpc_id, vpc_id))
    end

    it 'allows egress from the load balancer on all ports' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:from_port, 1)
              .with_attribute_value(:to_port, 65_535)
              .with_attribute_value(:protocol, 'tcp'))
    end

    it 'includes no ingress rules on the load balancer security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule',
                                          name: 'elb_ingress')
                  .with_attribute_value(:type, 'ingress'))
    end

    it 'outputs the load balancer security group ID' do
      expect(@plan)
        .to(include_output_creation(name: 'security_group_id'))
    end

    it 'creates a security group for traffic from the load balancer' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'open_to_load_balancer')
              .once)
    end

    it 'uses a name constructed from the component and deployment ' \
       'identifier for the open to load balancer security group' do
      name = "open-to-elb-#{component}-#{deployment_identifier}"
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'open_to_load_balancer')
              .with_attribute_value(:name, name))
    end

    it 'includes the component in the description for the open to load ' \
       'balancer security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'open_to_load_balancer')
              .with_attribute_value(:description, match(/.*#{component}.*/)))
    end

    it 'includes the deployment identifier in the description for the open ' \
       'to load balancer security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'open_to_load_balancer')
              .with_attribute_value(
                :description, match(/.*#{deployment_identifier}.*/)
              ))
    end

    it 'uses the provided VPC ID on the open to load balancer security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group',
                                      name: 'open_to_load_balancer')
              .with_attribute_value(:vpc_id, vpc_id))
    end

    it 'includes no ingress rules on the open to load balancer ' \
       'security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule',
                                          name: 'open_to_elb_ingress')
                  .with_attribute_value(:type, 'ingress'))
    end

    it 'outputs the open to load balancer security group ID' do
      expect(@plan)
        .to(include_output_creation(
              name: 'open_to_load_balancer_security_group_id'
            ))
    end
  end

  describe 'when one access control rule provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.listeners = [
          {
            lb_port: 80,
            lb_protocol: 'HTTP',
            instance_port: 8080,
            instance_protocol: 'HTTP',
            ssl_certificate_id: nil
          }
        ]
        vars.access_control = [
          {
            lb_port: 80,
            instance_port: 8080,
            allow_cidrs: ['10.0.0.0/8']
          }
        ]
      end
    end

    it 'creates an ingress rule for the load balancer security group for ' \
       'the load balancer port and provided allowed CIDRs' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule',
                                      name: 'elb_ingress')
                  .with_attribute_value(:type, 'ingress')
                  .with_attribute_value(:from_port, 80)
                  .with_attribute_value(:to_port, 80)
                  .with_attribute_value(:protocol, 'tcp')
                  .with_attribute_value(:cidr_blocks, ['10.0.0.0/8']))
    end

    it 'creates an ingress rule for the open to load balancer security ' \
       'group for the instance port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule',
                                      name: 'open_to_elb_ingress')
                  .with_attribute_value(:type, 'ingress')
                  .with_attribute_value(:from_port, 8080)
                  .with_attribute_value(:to_port, 8080)
                  .with_attribute_value(:protocol, 'tcp'))
    end
  end

  describe 'when many access control rules provided' do
    before(:context) do
      @access_control_rules = [
        {
          lb_port: 80,
          instance_port: 8080,
          allow_cidrs: ['10.0.0.0/8']
        },
        {
          lb_port: 443,
          instance_port: 8443,
          allow_cidrs: ['0.0.0.0/0']
        }
      ]
      @plan = plan(role: :root) do |vars|
        vars.listeners = [
          {
            lb_port: 80,
            lb_protocol: 'HTTP',
            instance_port: 8080,
            instance_protocol: 'HTTP',
            ssl_certificate_id: nil
          }
        ]
        vars.access_control = @access_control_rules
      end
    end

    it 'creates ingress rules for the load balancer security group for ' \
       'each provided load balancer port and allowed CIDRs' do
      @access_control_rules.each do |rule|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group_rule',
                                        name: 'elb_ingress')
                    .with_attribute_value(:type, 'ingress')
                    .with_attribute_value(:from_port, rule[:lb_port])
                    .with_attribute_value(:to_port, rule[:lb_port])
                    .with_attribute_value(:protocol, 'tcp')
                    .with_attribute_value(:cidr_blocks, rule[:allow_cidrs]))
      end
    end

    it 'creates an ingress rule for the open to load balancer security ' \
       'group for the instance port' do
      @access_control_rules.each do |rule|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group_rule',
                                        name: 'open_to_elb_ingress')
                    .with_attribute_value(:type, 'ingress')
                    .with_attribute_value(:from_port, rule[:instance_port])
                    .with_attribute_value(:to_port, rule[:instance_port])
                    .with_attribute_value(:protocol, 'tcp'))
      end
    end
  end

  describe 'when egress CIDRs provided' do
    before(:context) do
      @egress_cidrs = %w[10.1.0.0/16 10.2.0.0/16]
      @plan = plan(role: :root) do |vars|
        vars.listeners = [
          {
            lb_port: 80,
            lb_protocol: 'HTTP',
            instance_port: 8080,
            instance_protocol: 'HTTP',
            ssl_certificate_id: nil
          }
        ]
        vars.egress_cidrs = @egress_cidrs
      end
    end

    it 'uses the provided egress CIDRs on the egress rule from the ' \
       'load balancer' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:from_port, 1)
              .with_attribute_value(:to_port, 65_535)
              .with_attribute_value(:protocol, 'tcp')
              .with_attribute_value(:cidr_blocks, @egress_cidrs))
    end
  end
end
