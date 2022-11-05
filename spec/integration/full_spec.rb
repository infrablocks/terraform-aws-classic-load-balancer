# frozen_string_literal: true

require 'spec_helper'

describe 'full' do
  let(:component) do
    var(role: :full, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :full, name: 'deployment_identifier')
  end
  let(:domain_name) do
    var(role: :full, name: 'domain_name')
  end
  let(:public_zone_id) do
    var(role: :full, name: 'public_zone_id')
  end
  let(:private_zone_id) do
    var(role: :full, name: 'private_zone_id')
  end
  let(:name) do
    output(role: :full, name: 'name')
  end

  let(:public_hosted_zone) do
    route53_hosted_zone(public_zone_id)
  end
  let(:private_hosted_zone) do
    route53_hosted_zone(private_zone_id)
  end

  before(:context) do
    apply(role: :full)
  end

  after(:context) do
    destroy(
      role: :full,
      only_if: -> { !ENV['FORCE_DESTROY'].nil? || ENV['SEED'].nil? }
    )
  end

  describe 'DNS' do
    let(:load_balancer) do
      elb(name)
    end

    it 'outputs the address' do
      expect(output(role: :full, name: 'address'))
        .to(eq("#{component}-#{deployment_identifier}.#{domain_name}"))
    end

    it 'creates a public DNS entry' do
      expect(public_hosted_zone)
        .to(have_record_set(
          "#{component}-#{deployment_identifier}.#{domain_name}."
        )
              .alias(
                "#{load_balancer.dns_name}.",
                load_balancer.canonical_hosted_zone_name_id
              ))
    end

    it 'creates a private DNS entry' do
      expect(private_hosted_zone)
        .to(have_record_set(
          "#{component}-#{deployment_identifier}.#{domain_name}."
        )
              .alias(
                "#{load_balancer.dns_name}.",
                load_balancer.canonical_hosted_zone_name_id
              ))
    end
  end

  describe 'ELB' do
    subject(:load_balancer) do
      elb(name)
    end

    it { is_expected.to exist }

    its(:subnets) do
      is_expected
        .to(contain_exactly(*output(role: :full, name: 'subnet_ids')))
    end

    its(:scheme) { is_expected.to eq('internet-facing') }

    its(:health_check_target) do
      is_expected.to(eq('TCP:80'))
    end

    its(:health_check_timeout) do
      is_expected.to(eq(5))
    end

    its(:health_check_interval) do
      is_expected.to(eq(30))
    end

    its(:health_check_unhealthy_threshold) do
      is_expected.to(eq(2))
    end

    its(:health_check_healthy_threshold) do
      is_expected.to(eq(10))
    end

    it {
      expect(load_balancer)
        .to(have_listener(
              protocol: 'SSL',
              port: 6567,
              instance_protocol: 'SSL',
              instance_port: 6567
            ))
    }

    it {
      expect(load_balancer)
        .to(have_listener(
              protocol: 'HTTP',
              port: 80,
              instance_protocol: 'HTTP',
              instance_port: 80
            ))
    }

    it 'outputs the zone ID' do
      expect(output(role: :full, name: 'zone_id'))
        .to(eq(load_balancer.canonical_hosted_zone_name_id))
    end

    it 'outputs the DNS name' do
      expect(output(role: :full, name: 'dns_name'))
        .to(eq(load_balancer.dns_name))
    end

    it 'is associated with the load balancer security group' do
      expect(load_balancer)
        .to(have_security_group("elb-#{component}-#{deployment_identifier}"))
    end

    describe 'tags' do
      subject(:tags) do
        elb_client
          .describe_tags(load_balancer_names: [name])
          .tag_descriptions[0]
          .tags
          .map(&:to_h)
      end

      it {
        expect(tags)
          .to(include(
                key: 'Name',
                value: "elb-#{component}-#{deployment_identifier}"
              ))
      }

      it {
        expect(subject)
          .to(include(
                key: 'Component',
                value: component
              ))
      }

      it {
        expect(tags)
          .to(include(
                key: 'DeploymentIdentifier',
                value: deployment_identifier
              ))
      }
    end

    describe 'attributes' do
      subject(:load_balancer_attributes) do
        elb_client
          .describe_load_balancer_attributes(load_balancer_name: name)
          .load_balancer_attributes
      end

      it 'enables cross zone load balancing' do
        cross_zone_attribute =
          load_balancer_attributes.cross_zone_load_balancing.to_h

        expect(cross_zone_attribute)
          .to(eq(enabled: true))
      end

      it 'enables connection draining' do
        connection_draining_attribute =
          load_balancer_attributes.connection_draining

        expect(connection_draining_attribute.enabled)
          .to(eq(true))
      end

      it 'uses a connection draining timeout of 5 minutes' do
        connection_draining_attribute =
          load_balancer_attributes.connection_draining

        expect(connection_draining_attribute.timeout)
          .to(eq(300))
      end

      it 'uses an idle timeout of 60 seconds' do
        connection_settings_attribute =
          load_balancer_attributes.connection_settings

        expect(connection_settings_attribute.idle_timeout)
          .to(eq(60))
      end
    end
  end

  describe 'security groups' do
    describe 'for load balancer' do
      subject(:created_from_security_group) do
        security_group("elb-#{component}-#{deployment_identifier}")
      end

      it { is_expected.to exist }

      its(:vpc_id) do
        is_expected.to(eq(output(role: :full, name: 'vpc_id')))
      end

      its(:description) do
        is_expected
          .to(eq("ELB for component: #{component}, " \
                 "deployment: #{deployment_identifier}"))
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'allows inbound TCP connectivity for each listener for the ' \
         'supplied CIDRs' do
        expect(created_from_security_group.inbound_rule_count).to(eq(2))

        ingress_rule1 =
          created_from_security_group.ip_permissions.find do |permission|
            permission.from_port == 80
          end
        ingress_rule2 =
          created_from_security_group.ip_permissions.find do |permission|
            permission.from_port == 6567
          end

        expect(ingress_rule1.to_port).to(eq(80))
        expect(ingress_rule1.ip_protocol).to(eq('tcp'))
        expect(ingress_rule1.ip_ranges.map(&:cidr_ip)).to(eq(['0.0.0.0/0']))

        expect(ingress_rule2.to_port).to(eq(6567))
        expect(ingress_rule2.ip_protocol).to(eq('tcp'))
        expect(ingress_rule2.ip_ranges.map(&:cidr_ip)).to(eq(['10.0.0.0/8']))
      end
      # rubocop:enable RSpec/MultipleExpectations

      # rubocop:disable RSpec/MultipleExpectations
      it 'allows outbound TCP connectivity on all ports and protocols ' \
         'for the provided egress CIDRs' do
        expect(created_from_security_group.outbound_rule_count).to(be(1))

        egress_rule = created_from_security_group.ip_permissions_egress.first

        expect(egress_rule.from_port).to(eq(1))
        expect(egress_rule.to_port).to(eq(65_535))
        expect(egress_rule.ip_protocol).to(eq('tcp'))
        expect(egress_rule.ip_ranges.map(&:cidr_ip))
          .to(eq(['10.0.0.0/8']))
      end
      # rubocop:enable RSpec/MultipleExpectations

      it 'outputs the open to ELB security group ID' do
        expect(output(role: :full, name: 'security_group_id'))
          .to(eq(created_from_security_group.id))
      end
    end

    describe 'for instances' do
      subject(:created_to_security_group) do
        security_group("open-to-elb-#{component}-#{deployment_identifier}")
      end

      let(:load_balancer_security_group) do
        security_group("elb-#{component}-#{deployment_identifier}")
      end

      it { is_expected.to exist }

      its(:vpc_id) do
        is_expected.to(eq(output(role: :full, name: 'vpc_id')))
      end

      its(:description) do
        is_expected
          .to(eq("Open to ELB for component: #{component}, deployment: " \
                 "#{deployment_identifier}"))
      end

      it 'outputs the open to load balancer security group ID' do
        expect(output(role: :full,
                      name: 'open_to_load_balancer_security_group_id'))
          .to(eq(created_to_security_group.id))
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'allows inbound TCP connectivity for each listener for the load ' \
         'balancer security group' do
        expect(created_to_security_group.inbound_rule_count).to(eq(2))

        ingress_rule1 =
          created_to_security_group.ip_permissions.find do |permission|
            permission.from_port == 80
          end
        ingress_rule2 =
          created_to_security_group.ip_permissions.find do |permission|
            permission.from_port == 6567
          end

        expect(ingress_rule1.to_port).to(eq(80))
        expect(ingress_rule1.ip_protocol).to(eq('tcp'))
        expect(ingress_rule1.user_id_group_pairs[0].group_id)
          .to(eq(load_balancer_security_group.id))

        expect(ingress_rule2.to_port).to(eq(6567))
        expect(ingress_rule2.ip_protocol).to(eq('tcp'))
        expect(ingress_rule2.user_id_group_pairs[0].group_id)
          .to(eq(load_balancer_security_group.id))
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
