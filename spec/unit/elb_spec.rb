# frozen_string_literal: true

require 'spec_helper'

describe 'ELB' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:subnet_ids) do
    output(role: :prerequisites, name: 'subnet_ids')
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

    it 'creates an ELB' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .once)
    end

    it 'uses the provided subnet IDs' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(
                :subnets, containing_exactly(*subnet_ids)
              ))
    end

    it 'marks the ELB as internal' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:internal, true))
    end

    it 'enables cross zone load balancing' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:cross_zone_load_balancing, true))
    end

    it 'does not enable connection draining' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:connection_draining, false))
    end

    it 'uses an idle timeout of 60 seconds' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:idle_timeout, 60))
    end

    it 'uses a health check target of "TCP:80"' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value([:health_check, 0, :target], 'TCP:80'))
    end

    it 'uses a health check timeout of 5' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value([:health_check, 0, :timeout], 5))
    end

    it 'uses a health check interval of 30' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value([:health_check, 0, :interval], 30))
    end

    it 'uses a health check unhealthy threshold of 2' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(
                [:health_check, 0, :unhealthy_threshold], 2
              ))
    end

    it 'uses a health check healthy threshold of 10' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(
                [:health_check, 0, :healthy_threshold], 10
              ))
    end

    it 'adds tags to the ELB' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(
                :tags,
                {
                  Name: "elb-#{component}-#{deployment_identifier}",
                  Component: component,
                  DeploymentIdentifier: deployment_identifier
                }
              ))
    end

    it 'adds the provided listener' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(
                [:listener, 0],
                {
                  lb_port: 80,
                  lb_protocol: 'HTTP',
                  instance_port: 8080,
                  instance_protocol: 'HTTP',
                  ssl_certificate_id: ''
                }
              ))
    end
  end

  describe 'when multiple listeners provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.expose_to_public_internet = 'yes'
        vars.listeners = [
          {
            lb_port: 80,
            lb_protocol: 'HTTP',
            instance_port: 8080,
            instance_protocol: 'HTTP',
            ssl_certificate_id: nil
          },
          {
            lb_port: 443,
            lb_protocol: 'HTTPS',
            instance_port: 8443,
            instance_protocol: 'HTTPS',
            ssl_certificate_id:
              output(role: :prerequisites, name: 'certificate_arn')
          }
        ]
      end
    end

    it 'adds the provided listeners' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(
                :listener,
                containing_exactly(
                  {
                    lb_port: 80,
                    lb_protocol: 'HTTP',
                    instance_port: 8080,
                    instance_protocol: 'HTTP',
                    ssl_certificate_id: ''
                  },
                  {
                    lb_port: 443,
                    lb_protocol: 'HTTPS',
                    instance_port: 8443,
                    instance_protocol: 'HTTPS',
                    ssl_certificate_id:
                      output(role: :prerequisites, name: 'certificate_arn')
                  }
                )))
    end
  end

  describe 'when expose_to_public_internet is "yes"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.expose_to_public_internet = 'yes'
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

    it 'marks the ELB as internet-facing' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:internal, false))
    end
  end

  describe 'when expose_to_public_internet is "no"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.expose_to_public_internet = 'no'
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

    it 'marks the ELB as internal' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:internal, true))
    end
  end

  describe 'when enable_cross_zone_load_balancing is "yes"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_cross_zone_load_balancing = 'yes'
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

    it 'enables cross zone load balancing' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:cross_zone_load_balancing, true))
    end
  end

  describe 'when enable_cross_zone_load_balancing is "no"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_cross_zone_load_balancing = 'no'
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

    it 'disables cross zone load balancing' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:cross_zone_load_balancing, false))
    end
  end

  describe 'when enable_connection_draining is "yes" and ' \
           'connection timeout not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_connection_draining = 'yes'
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

    it 'enables connection draining' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:connection_draining, true))
    end

    it 'uses a connection draining timeout of 300 seconds' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:connection_draining_timeout, 300))
    end
  end

  describe 'when enable_connection_draining is "yes" and ' \
           'connection draining timeout provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_connection_draining = 'yes'
        vars.connection_draining_timeout = 180
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

    it 'enables connection draining' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:connection_draining, true))
    end

    it 'uses the provided connection draining timeout' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:connection_draining_timeout, 180))
    end
  end

  describe 'when enable_connection_draining is "no"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_connection_draining = 'no'
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

    it 'disables connection draining' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:connection_draining, false))
    end
  end

  describe 'when idle timeout is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.idle_timeout = 120
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

    it 'uses the provided idle timeout' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(:idle_timeout, 120))
    end
  end

  describe 'when health check attributes provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.health_check_target = 'HTTP:80/health'
        vars.health_check_timeout = 10
        vars.health_check_interval = 60
        vars.health_check_unhealthy_threshold = 5
        vars.health_check_healthy_threshold = 8
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

    it 'uses the provided health check target' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(
                [:health_check, 0, :target], 'HTTP:80/health'
              ))
    end

    it 'uses the provided health check timeout' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value([:health_check, 0, :timeout], 10))
    end

    it 'uses the provided health check interval' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value([:health_check, 0, :interval], 60))
    end

    it 'uses the provided health check unhealthy threshold' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(
                [:health_check, 0, :unhealthy_threshold], 5
              ))
    end

    it 'uses the provided health check healthy threshold' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_elb')
              .with_attribute_value(
                [:health_check, 0, :healthy_threshold], 8
              ))
    end
  end

  #   it {
  #     expect(created_elb)
  #       .to(have_listener(
  #             protocol:
  #               configuration
  #                 .for(:root)
  #                 .listener_1_lb_protocol,
  #             port:
  #               configuration
  #                 .for(:root)
  #                 .listener_1_lb_port
  #                 .to_i,
  #             instance_protocol:
  #               configuration
  #                 .for(:root)
  #                 .listener_1_instance_protocol,
  #             instance_port:
  #               configuration
  #                 .for(:root)
  #                 .listener_1_instance_port
  #                 .to_i
  #           ))
  #   }
  #
  #   it {
  #     expect(created_elb)
  #       .to(have_listener(
  #             protocol:
  #               configuration
  #                 .for(:root)
  #                 .listener_2_lb_protocol,
  #             port:
  #               configuration
  #                 .for(:root)
  #                 .listener_2_lb_port
  #                 .to_i,
  #             instance_protocol:
  #               configuration
  #                 .for(:root)
  #                 .listener_2_instance_protocol,
  #             instance_port:
  #               configuration
  #                 .for(:root)
  #                 .listener_2_instance_port
  #                 .to_i
  #           ))
  #   }
  #
  #   it 'outputs the zone ID' do
  #     expect(output(role: :root, name: 'zone_id'))
  #       .to(eq(created_elb.canonical_hosted_zone_name_id))
  #   end
  #
  #   it 'outputs the DNS name' do
  #     expect(output(role: :root, name: 'dns_name'))
  #       .to(eq(created_elb.dns_name))
  #   end
  #
  #   it 'is associated with the load balancer security group' do
  #     expect(created_elb)
  #       .to(have_security_group("elb-#{component}-#{deployment_identifier}"))
  #   end
  #
end
