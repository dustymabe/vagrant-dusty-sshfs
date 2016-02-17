require "vagrant/util/retryable"

module VagrantPlugins
  module GuestLinux
    module Cap
      class MountSSHFS
        extend Vagrant::Util::Retryable

        def self.mount_sshfs_folder(machine, ip, folders)
          folders.each do |name, opts|
            # Expand the guest path so we can handle things like "~/vagrant"
            expanded_guest_path = machine.guest.capability(
              :shell_expand_guest_path, opts[:guestpath])

            # Do the actual creating and mounting
            machine.communicate.sudo("mkdir -p #{expanded_guest_path}")

            # Mount
            hostpath = opts[:hostpath].dup
            hostpath.gsub!("'", "'\\\\''")

            # Figure out any options
            mount_opts = []
           #mount_opts = ["vers=#{opts[:nfs_version]}"]
           #mount_opts << "udp" if opts[:nfs_udp]
           #if opts[:mount_options]
           #  mount_opts = opts[:mount_options].dup
           #end

          mount_opts = '-o StrictHostKeyChecking=no '
          mount_opts+= '-o allow_other '
          mount_opts+= '-o noauto_cache '
#mount_opts+= "-p #{port} "
          #options+= '-o kernel_cache -o Ciphers=arcfour -o big_writes -o auto_cache -o cache_timeout=115200 -o attr_timeout=115200 -o entry_timeout=1200 -o max_readahead=90000 '
          #options+= '-o kernel_cache -o big_writes -o auto_cache -o cache_timeout=115200 -o attr_timeout=115200 -o entry_timeout=1200 -o max_readahead=90000 '
          #options+= '-o cache_timeout=3600 '

         ## Grab password if necessary
         #sshpass = password()
         #echopipe = ""
         #if sshpass
         #  echopipe= "echo " + sshpass + " | "
         #  options+= '-o password_stdin '
         #end

            mount_command = "sshfs " + mount_opts + "dustymabe@#{ip}:'#{hostpath}' #{expanded_guest_path}"
#mount_command = "mount -o '#{mount_opts.join(",")}' #{ip}:'#{hostpath}' #{expanded_guest_path}"
            retryable(on: VagrantPlugins::SyncedFolderSSHFS::Errors::LinuxSSHFSMountFailed, tries: 8, sleep: 3) do
              machine.communicate.sudo(mount_command,
                                       error_class: VagrantPlugins::SyncedFolderSSHFS::Errors::LinuxSSHFSMountFailed)
            end

           ## Emit an upstart event if we can
           #if machine.communicate.test("test -x /sbin/initctl")
           #  machine.communicate.sudo(
           #    "/sbin/initctl emit --no-wait vagrant-mounted MOUNTPOINT=#{expanded_guest_path}")
           #end
          end
        end
      end
    end
  end
end
