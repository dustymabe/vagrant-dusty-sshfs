require "vagrant"

module VagrantPlugins
  module SyncedFolderSSHFS
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :functional
      attr_accessor :map_uid
      attr_accessor :map_gid

      def initialize
        super

        @functional = UNSET_VALUE
        @map_uid    = UNSET_VALUE
        @map_gid    = UNSET_VALUE
      end

      def finalize!
        @functional = true if @functional == UNSET_VALUE
        @map_uid = :auto if @map_uid == UNSET_VALUE
        @map_gid = :auto if @map_gid == UNSET_VALUE
      end

      def to_s
        "NFS"
      end
    end
  end
end

module Vagrant
  module SshFS
    class Config < Vagrant.plugin(2, :config)
      attr_accessor :paths
      attr_accessor :username
      attr_accessor :enabled
      attr_accessor :prompt_create_folders
      attr_accessor :sudo
      attr_accessor :mount_on_guest
      attr_accessor :host_addr

      def initialize
        @paths = {}
        @username = nil
        @enabled = true
        @prompt_create_folders = false
        @sudo = true
      end

      def merge(other)
        super.tap do |result|
          result.paths = @paths.merge(other.paths)
        end
      end
    end
  end
end
