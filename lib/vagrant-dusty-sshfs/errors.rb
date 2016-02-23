module VagrantPlugins
  module SyncedFolderSSHFS
    module Errors
      # A convenient superclass for all our errors.
      class SSHFSError < Vagrant::Errors::VagrantError
        error_namespace("vagrant.sshfs.errors")
      end

      class SSHFSMountFailed < SSHFSError
        error_key(:mount_failed)
      end

      class SSHFSNotInstalledInGuest < SSHFSError
        error_key(:sshfs_not_in_guest)
      end
    end
  end
end
