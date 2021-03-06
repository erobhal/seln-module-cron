require 'spec_helper'
describe 'cron' do

  platforms = {
    'RedHat' =>
      {
        :osfamily     => 'RedHat',
        :package_name => 'crontabs',
        :service_name => 'crond',
      },
    'Suse' =>
      {
        :osfamily     => 'Suse',
        :package_name => 'cron',
        :service_name => 'cron',
      },
    'Debian' =>
      {
        :osfamily     => 'Debian',
        :package_name => 'cron',
        :service_name => 'cron',
      },
    'Ubuntu' =>
      {
        :osfamily     => 'Ubuntu',
        :package_name => 'cron',
        :service_name => 'cron',
      },
  }

  describe 'with default values for parameters' do
    platforms.sort.each do |k,v|
      context "where osfamily is <#{v[:osfamily]}>" do
        let :facts do
          {
            :osfamily          => v[:osfamily],
          }
        end

        it {
          should contain_file('cron_allow').with({
            'ensure'  => 'absent',
            'path'    => '/etc/cron.allow',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_file('cron_deny').with({
            'ensure'  => 'absent',
            'path'    => '/etc/cron.deny',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_package("#{v[:package_name]}").with({
            'ensure' => 'present',
            'name'   => v[:package_name],
          })
        }

        it {
          should contain_file('crontab').with({
            'ensure'  => 'present',
            'path'    => '/etc/crontab',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_service('cron').with({
            'ensure'    => 'running',
            'enable'    => true,
            'name'      => v[:service_name],
            'require'   => 'File[crontab]',
            'subscribe' => 'File[crontab]',
          })
        }

      end
    end

   describe 'on unsupported platform' do
     context 'Redhat > 7' do
     let(:facts) { {
       :osfamily                  => 'RedHat',
       :operatingsystemmajrelease => '8',
     } }
       it 'should fail' do
         expect {
           should contain_class('cron')
         }.to raise_error(Puppet::Error,/This cron module supports Redhat versions up to/)
       end
     end
     context 'SuSE > 11' do
     let(:facts) { {
       :osfamily                  => 'Suse',
       :lsbmajdistrelease         => '13',
     } }
       it 'should fail' do
         expect {
           should contain_class('cron')
         }.to raise_error(Puppet::Error,/This cron module supports SuSE versions up to/)
       end
     end
   end

    context "crontab on RedHat 5" do
      let :facts do
        {
          :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '5.5',
        }
      end
      it {
        should contain_file('crontab').with({
          'content' => File.read(fixtures("default_crontab-RedHat-5.5")),
        })
      }
    end

    context "crontab on RedHat 6" do
      let :facts do
        {
          :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '6.7',
        }
      end
      it {
        should contain_file('crontab').with({
          'content' => File.read(fixtures("default_crontab-RedHat-6.7")),
        })
      }
    end

    context "crontab on RedHat 7" do
      let :facts do
        {
          :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '7.1',
        }
      end
      it {
        should contain_file('crontab').with({
          'content' => File.read(fixtures("default_crontab-RedHat-7.1")),
        })
      }
    end

    context "crontab on Suse 10" do
      let :facts do
        {
          :osfamily                  => 'Suse',
          :operatingsystemrelease    => '10.4',
        }
      end
      it {
        should contain_file('crontab').with({
          'content' => File.read(fixtures("default_crontab-Suse-10.4")),
        })
      }
    end

    context "crontab on Suse 11" do
      let :facts do
        {
          :osfamily                  => 'Suse',
          :operatingsystemrelease    => '11.3',
        }
      end
      it {
        should contain_file('crontab').with({
          'content' => File.read(fixtures("default_crontab-Suse-11.3")),
        })
      }
    end

    context "crontab on Suse 12" do
      let :facts do
        {
          :osfamily                  => 'Suse',
          :operatingsystemrelease    => '12.1',
        }
      end
      it {
        should contain_file('crontab').with({
          'content' => File.read(fixtures("default_crontab-Suse-12.1")),
        })
      }
    end


  end

  describe 'with optional parameters set' do
    platforms.sort.each do |k,v|
      context "where osfamily is <#{v[:osfamily]}>" do
        let :facts do
          {
            :osfamily          => v[:osfamily],
          }
        end

        context 'where enable_cron is <false>' do
          let :params do
            {
              :enable_cron => 'false',
            }
          end

          it {
            should contain_service('cron').with({
              'ensure'  => 'running',
              'enable'  => false,
              'name'    => v[:service_name],
              'require'   => 'File[crontab]',
              'subscribe' => 'File[crontab]',
            })
          }
        end

        context 'where package_ensure is <absent>' do
          let :params do
            {
              :package_ensure => 'absent',
            }
          end

          it {
            should contain_package("#{v[:package_name]}").with({
              'ensure' => 'absent',
              'name'   => v[:package_name],
            })
          }
        end

        context 'where ensure_state is <stopped>' do
          let :params do
            {
              :ensure_state => 'stopped',
            }
          end

          it {
            should contain_service('cron').with({
              'ensure'    => 'stopped',
              'enable'    => true,
              'name'      => v[:service_name],
              'require'   => 'File[crontab]',
              'subscribe' => 'File[crontab]',
            })
          }
        end

        context 'where crontab_path is </somewhere/else>' do
          let :params do
            {
              :crontab_path => '/somewhere/else',
            }
          end

          it {
            should contain_file('crontab').with({
              'ensure'  => 'present',
              'path'    => '/somewhere/else',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron_allow is <present>' do
          let :params do
            {
              :cron_allow => 'present',
            }
          end

          it {
            should contain_file('cron_allow').with({
              'ensure'  => 'present',
              'path'    => '/etc/cron.allow',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{platforms[v[:osfamily]][:package_name]}]",
            })
          }
          it { should contain_file('cron_allow').with_content(/^# File managed by puppet$/) }
        end

        context 'where cron_deny is <present>' do
          let :params do
            {
              :cron_deny => 'present',
            }
          end

          it {
            should contain_file('cron_deny').with({
              'ensure'  => 'present',
              'path'    => '/etc/cron.deny',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{platforms[v[:osfamily]][:package_name]}]",
            })
          }
          it { should contain_file('cron_deny').with_content(/^# File managed by puppet\n# Do not edit manually$/) }
        end

        context 'where cron_allow_path is </somwhere/else/allow>' do
          let :params do
            {
              :cron_allow_path => '/somwhere/else/allow',
            }
          end

          it {
            should contain_file('cron_allow').with({
              'ensure'  => 'absent',
              'path'    => '/somwhere/else/allow',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{platforms[v[:osfamily]][:package_name]}]",
            })
          }
          it { should contain_file('cron_allow').with_content(/^# File managed by puppet$/) }
        end

        context 'where cron_deny_path is </somewhere/else/deny>' do
          let :params do
            {
              :cron_deny_path => '/somewhere/else/deny',
            }
          end

          it {
            should contain_file('cron_deny').with({
              'ensure'  => 'absent',
              'path'    => '/somewhere/else/deny',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{platforms[v[:osfamily]][:package_name]}]",
            })
          }
          it { should contain_file('cron_deny').with_content(/^# File managed by puppet\n# Do not edit manually$/) }
        end

# TODO: test for cron_files

        context 'where cron_allow_users is <[ \'Tintin\', \'Milou\' ]>' do
          let :params do
            {
              :cron_allow_users => [ 'Tintin', 'Milou', ],
            }
          end

          it {
            should contain_file('cron_allow').with({
              'ensure'  => 'present',
              'path'    => '/etc/cron.allow',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{platforms[v[:osfamily]][:package_name]}]",
            })
          }
          it { should contain_file('cron_allow').with_content(/^# File managed by puppet\n# Do not edit manually$/) }
          it { should contain_file('cron_allow').with_content(/^Tintin\nMilou$/) }
        end

        context 'where cron_deny_users is <[ \'nobody\', \'anyone\' ]>' do
          let :params do
            {
              :cron_deny_users => [ 'nobody', 'anyone', ],
            }
          end

          it {
            should contain_file('cron_deny').with({
              'ensure'  => 'present',
              'path'    => '/etc/cron.deny',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{platforms[v[:osfamily]][:package_name]}]",
            })
          }
          it { should contain_file('cron_deny').with_content(/^# File managed by puppet\n# Do not edit manually$/) }
          it { should contain_file('cron_deny').with_content(/^nobody\nanyone$/) }
        end

        context 'where crontab_vars is <{ \'MAILTO\' => \'operator\', \'SHELL\' => \'/bin/tcsh\' }>' do
          let :params do
            {
              :crontab_vars => {
                'MAILTO' => 'operator',
                'SHELL'  => '/bin/tcsh',
              }
            }
          end

          it {
            should contain_file('crontab').with({
              'ensure'  => 'present',
              'path'    => '/etc/crontab',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
          it { should contain_file('crontab').with_content(/^### Crontab File managed by Puppet\n### DOT NOT change it manually$/) }
          it { should contain_file('crontab').with_content(/^MAILTO=operator\nSHELL=\/bin\/tcsh$/) }
        end

        context 'where crontab_tasks is <{ spec_test => [ \'42 * * * * nobody echo task1\' ]>' do
          let :params do
            {
              :crontab_tasks => {
                'spec_test' => [ '42 * * * * nobody echo task1' ],
              }
            }
          end

          it {
            should contain_file('crontab').with({
              'ensure'  => 'present',
              'path'    => '/etc/crontab',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
          it { should contain_file('crontab').with_content(/^### Crontab File managed by Puppet\n### DOT NOT change it manually$/) }
          it { should contain_file('crontab').with_content(/^# spec_test\n42 \* \* \* \* nobody echo task1$/) }

       end

      end
    end
  end

end
