# Temporary fix for error caused by third party gems. See:
# https://github.com/maestrodev/puppet-blacksmith/issues/14
# https://github.com/dfarrell07/puppet-opendaylight/issues/6
require 'puppet/version'
require 'puppet/vendor/semantic/lib/semantic' unless Puppet.version.to_f <3.6

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These two gems aren't always present, for instance
# on Travis with `--without local_only`
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

PuppetLint.configuration.relative = true
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

# Forsake support for Puppet 2.6.2 for the benefit of cleaner code.
# http://puppet-lint.com/checks/class_parameter_defaults/
PuppetLint.configuration.send('disable_class_parameter_defaults')
# http://puppet-lint.com/checks/class_inherits_from_params_class/
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

exclude_paths = [
  "bundle/**/*",
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

# Linting

task :metadata_lint do
  sh "metadata-json-lint metadata.json"
end

task :travis_lint do
  # Using "echo y" to accept interactive "install shell completion?" prompt
  sh 'echo "y" | travis lint .travis.yml --debug'
end

# TODO: Add Coala helper

# CentOS VMs

desc "Beaker tests against CentOS 7 VM with latest Boron testing RPM"
task :cent_5test_vm do
  sh "RS_SET=centos-7 INSTALL_METHOD=rpm RPM_REPO='opendaylight-5-testing' bundle exec rake beaker"
end

desc "Beaker tests against CentOS 7 VM with latest Carbon testing RPM"
task :cent_6test_vm do
  sh "RS_SET=centos-7 INSTALL_METHOD=rpm RPM_REPO='opendaylight-6-testing' bundle exec rake beaker"
end

desc "Beaker tests against CentOS 7 VM with latest Boron release RPM"
task :cent_5rel_vm do
  sh "RS_SET=centos-7 INSTALL_METHOD=rpm RPM_REPO='opendaylight-5-release' bundle exec rake beaker"
end

# CentOS Containers

desc "Beaker tests against CentOS 7 container with latest Boron testing RPM"
task :cent_5test_dock do
  sh "RS_SET=centos-7-docker INSTALL_METHOD=rpm RPM_REPO='opendaylight-5-testing' bundle exec rake beaker"
end

desc "Beaker tests against CentOS 7 container with latest Carbon testing RPM"
task :cent_6test_dock do
  sh "RS_SET=centos-7-docker INSTALL_METHOD=rpm RPM_REPO='opendaylight-6-testing' bundle exec rake beaker"
end

desc "Beaker tests against CentOS 7 container with latest Boron release RPM"
task :cent_5rel_dock do
  sh "RS_SET=centos-7-docker INSTALL_METHOD=rpm RPM_REPO='opendaylight-5-release' bundle exec rake beaker"
end

# Ubuntu VMs

desc "Beaker tests against Ubuntu 16.04 VM with Boron release Deb"
task :ubuntu_5rel_vm do
  sh "RS_SET=ubuntu-16 INSTALL_METHOD=deb DEB_REPO='ppa:odl-team/boron' bundle exec rake beaker"
end

# Ubuntu Containers

desc "Beaker tests against Ubuntu 16.04 Container with Boron release Deb"
task :ubuntu_5rel_dock do
  sh "RS_SET=ubuntu-16-docker INSTALL_METHOD=deb DEB_REPO='ppa:odl-team/boron' bundle exec rake beaker"
end


# Multi-test helpers

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :metadata_lint,
  :travis_lint,
  :spec,
]

desc "Quick and important tests"
task :sanity=> [
  :test,
  :cent_6test_dock,
]

desc "All tests, use VMs for Beaker tests"
task :acceptance_vm => [
  :test,
  :cent_5rel_vm,
  :ubuntu_5rel_vm,
  :cent_5test_vm,
  :cent_6test_vm,
]

desc "All tests, use containers for Beaker tests"
task :acceptance_dock => [
  :test,
  :cent_5rel_dock,
  :ubuntu_5rel_dock,
  :cent_5test_dock,
  :cent_6test_dock,
]
