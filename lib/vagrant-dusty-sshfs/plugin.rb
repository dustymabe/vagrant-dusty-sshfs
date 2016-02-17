require "vagrant"

module VagrantPlugins
  module SyncedFolderSSHFS
    # This plugin implements SSHFS synced folders. In order to take advantage
    # of SSHFS synced folders, some provider-specific assistance is required.
    # Within the middleware sequences, some data must be put into the
    # environment state bag:
    #
    #   * `nfs_host_ip` (string) - The IP of the host machine that the NFS
    #     client in the machine should talk to.
    #   * `nfs_machine_ip` (string) - The IP of the guest machine that the NFS
    #     server should serve the folders to.
    #   * `nfs_valid_ids` (array of strings) - A list of IDs that are "valid"
    #     and should not be pruned. The synced folder implementation will
    #     regularly prune NFS exports of invalid IDs.
    #
    # If any of these variables are not set, an internal exception will be
    # raised.
    #
    class Plugin < Vagrant.plugin("2")
      name "SSHFS synced folders"
      description <<-EOF
      The SSHFS synced folders plugin enables you to use SSHFS as a synced folder
      implementation.
      EOF

     #config("sshfs") do
     #  require_relative "config"
     #  Config
     #end

      synced_folder("sshfs", 5) do
        require_relative "synced_folder"
        SyncedFolder
      end

      # Is this really linux specific?
      guest_capability("linux", "mount_sshfs_folder") do
        require_relative "cap/linux/mount_sshfs"
        VagrantPlugins::GuestLinux::Cap::MountSSHFS
      end

    ##action_hook("nfs_cleanup") do |hook|
    ##  require_relative "action_cleanup"
    ##  hook.before(
    ##    Vagrant::Action::Builtin::SyncedFolderCleanup,
    ##    ActionCleanup)
    ##end
    end
  end
end
