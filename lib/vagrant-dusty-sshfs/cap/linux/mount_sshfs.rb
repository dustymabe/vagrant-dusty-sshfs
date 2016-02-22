require "vagrant/util/retryable"

module VagrantPlugins
  module GuestLinux
    module Cap
      class MountSSHFS
        extend Vagrant::Util::Retryable

        #def self.mount_sshfs_folder(machine, ip, folders)
        def self.mount_sshfs_folder(machine, opts)
          # opts contains something like:
          #   { :type=>:sshfs,
          #     :guestpath=>"/sharedfolder",
          #     :hostpath=>"/guests/sharedfolder", 
          #     :disabled=>false
          #     :ssh_host=>"192.168.1.1"
          #     :ssh_port=>"22"
          #     :ssh_username=>"username"
          #     :ssh_password=>"password"
          #   }

          # expand the guest path so we can handle things like "~/vagrant"
          expanded_guest_path = machine.guest.capability(
            :shell_expand_guest_path, opts[:guestpath])

          # Do the actual creating and mounting
          machine.communicate.sudo("mkdir -p #{expanded_guest_path}")

          # Mount path information
          hostpath = opts[:hostpath].dup
          hostpath.gsub!("'", "'\\\\''")

          # Figure out any options
          # TODO - Allow options override via an option
          mount_opts = '-o StrictHostKeyChecking=no '
          mount_opts+= '-o allow_other '
          mount_opts+= '-o noauto_cache '

          # TODO some other options we might use in the future to help
          # connections over low bandwidth
          #options+= '-o kernel_cache -o Ciphers=arcfour -o big_writes -o auto_cache -o cache_timeout=115200 -o attr_timeout=115200 -o entry_timeout=1200 -o max_readahead=90000 '
          #options+= '-o kernel_cache -o big_writes -o auto_cache -o cache_timeout=115200 -o attr_timeout=115200 -o entry_timeout=1200 -o max_readahead=90000 '
          #options+= '-o cache_timeout=3600 '


          username = opts[:ssh_username]
          password = opts[:ssh_password]
          host     = opts[:ssh_host]
          port     = opts[:ssh_port]

          echopipe = ""
          #if opts.has_key?(:ssh_password) and opts[:ssh_password]
          if password
            echopipe = "echo '#{password}' | "
            mount_opts+= '-o password_stdin '
          end
          
          error_class = VagrantPlugins::SyncedFolderSSHFS::Errors::LinuxSSHFSMountFailed
          cmd = echopipe + "sshfs -p #{port} " + mount_opts + "#{username}@#{host}:'#{hostpath}' #{expanded_guest_path}"
          retryable(on: VagrantPlugins::SyncedFolderSSHFS::Errors::LinuxSSHFSMountFailed, tries: 8, sleep: 3) do
            machine.communicate.sudo(cmd, error_class: error_class)
          end
        end
      end
    end
  end
end
