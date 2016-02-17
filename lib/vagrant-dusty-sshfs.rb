begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant sshfs plugin must be run within Vagrant"
end

require "vagrant-dusty-sshfs/errors"
require "vagrant-dusty-sshfs/version"
require "vagrant-dusty-sshfs/plugin"

module VagrantPlugins
  module SyncedFolderSSHFS
    # Returns the path to the source of this plugin
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
