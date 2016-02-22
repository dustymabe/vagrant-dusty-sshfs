require "vagrant"

module VagrantPlugins
  module SyncedFolderSSHFS
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :ssh_username
      attr_accessor :ssh_password

      def initialize
        super

        @ssh_username = UNSET_VALUE
        @ssh_password = UNSET_VALUE
      end

      def finalize!
        @ssh_username = nil if @ssh_username = UNSET_VALUE
        @ssh_password = nil if @ssh_password = UNSET_VALUE
      end

      def to_s
        "SSHFS"
      end
    end
  end
end

#   module Vagrant
#     module SshFS
#       class Config < Vagrant.plugin(2, :config)
#         attr_accessor :paths
#         attr_accessor :username
#         attr_accessor :enabled
#         attr_accessor :prompt_create_folders
#         attr_accessor :sudo
#         attr_accessor :mount_on_guest
#         attr_accessor :host_addr

#         def initialize
#           @paths = {}
#           @username = nil
#           @enabled = true
#           @prompt_create_folders = false
#           @sudo = true
#         end

#         def merge(other)
#           super.tap do |result|
#             result.paths = @paths.merge(other.paths)
#           end
#         end
#       end
#     end
#   end
