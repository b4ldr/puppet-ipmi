require 'spec_helper'

describe 'ipmi' do
  let(:node) { 'ipmi.example.com' }
  let(:params) { {} }

  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      case facts['os']['family']
      when 'Redhat'
        let(:conf_file) { '/etc/sysconfig/ipmi' }
        let(:packages) { ['OpenIPMI', 'ipmitool'] }
        let(:ipmi_service_name) { 'ipmi' }
      else
        let(:conf_file) { '/etc/default/openipmi' }
        let(:packages) { ['openipmi', 'ipmitool'] }
        let(:ipmi_service_name) { 'openipmi' }
      end
      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it do
          packages.each do |package|
            is_expected.to contain_package(package)
          end
        end
        it do
          is_expected.to contain_augeas(conf_file).with(
            context: "/files#{conf_file}",
            changes: ['set IPMI_WATCHDOG no'],
            notify: "Service['#{ipmi_service_name}', 'ipmievd']",
          )
        end
        it do
          is_expected.to contain_service(ipmi_service_name).with(
            ensure: 'running',
            enable: 'true',
          )
        end
        it do
          is_expected.to contain_service('ipmievd').with(
            ensure: 'stopped'
            enable: 'false',
          )
        end
      end
      describe 'Change Defaults' do
        context 'packages' do
          before { params.merge!(packages: ['foobar']) }
          it { is_expected.to compile }
          it { is_expected.to contain_package('foobar') }
        end
        context 'conf_file' do
          before { params.merge!(conf_file: '/foo/bar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_augeas('/foo/bar').with(
              context: "/files/foo/bar",
              changes: ['set IPMI_WATCHDOG no'],
              notify: "Service['#{ipmi_service_name}', 'ipmievd']",
            )
          end
        end
        context 'ipmi_service_name' do
          before { params.merge!(ipmi_service_name: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_service('foobar').with(
              ensure: 'running'
              enable: 'true',
            )
          end
        end
        context 'ipmi_service_ensure' do
          before { params.merge!(ipmi_service_ensure: 'stopped') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_service(ipmievd_service_name).with(
              ensure: 'stopped'
              enable: 'false',
            )
          end
        end
        context 'ipmievd_service_name' do
          before { params.merge!(ipmievd_service_name: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_service('foobar').with(
              ensure: 'stopped'
              enable: 'false',
            )
          end
        end
        context 'ipmievd_service_ensure' do
          before { params.merge!(ipmievd_service_ensure: 'running') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_service('foobar').with(
              ensure: 'running'
              enable: 'true',
            )
          end
        end
        context 'watchdog' do
          before { params.merge!(watchdog: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_augeas(conf_file).with(
              context: "/files#{conf_file}",
              changes: ['set IPMI_WATCHDOG yes'],
              notify: "Service['#{ipmi_service_name}', 'ipmievd']",
            )
          end
        end
      end
      describe 'check bad type' do
        context 'packages' do
          before { params.merge!(packages: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'conf_file' do
          before { params.merge!(conf_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ipmi_service_name' do
          before { params.merge!(ipmi_service_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ipmi_service_ensure' do
          before { params.merge!(ipmi_service_ensure: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ipmievd_service_name' do
          before { params.merge!(ipmievd_service_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ipmievd_service_ensure' do
          before { params.merge!(ipmievd_service_ensure: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'watchdog' do
          before { params.merge!(watchdog: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'snmps' do
          before { params.merge!(snmps: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'users' do
          before { params.merge!(users: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'networks' do
          before { params.merge!(networks: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
