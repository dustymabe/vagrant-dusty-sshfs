module VagrantPlugins
  module SyncedFolderSSHFS
    module Errors
      # A convenient superclass for all our errors.
      class SSHFSError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_sf_sshfs.errors")
      end

      class LinuxSSHFSMountFailed < SSHFSError
        error_key(:share_mount_failed)
      end
    end
  end
end
