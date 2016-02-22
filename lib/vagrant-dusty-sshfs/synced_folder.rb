require 'fileutils'
require 'thread'
require 'zlib'

require "log4r"

require "vagrant/util/platform"

module VagrantPlugins
  module SyncedFolderSSHFS
    # This synced folder requires that two keys be set on the environment
    # within the middleware sequence:
    #
    #   - `:nfs_host_ip` - The IP of where to mount the NFS folder from.
    #   - `:nfs_machine_ip` - The IP of the machine where the NFS folder
    #     will be mounted.
    #
    class SyncedFolder < Vagrant.plugin("2", :synced_folder)
      @@lock = Mutex.new
      @@vagrant_host_machine_ip

      def initialize(*args)
        super

        @logger = Log4r::Logger.new("vagrant::synced_folders::sshfs")
        @@vagrant_host_machine_ip = nil
      end

      def usable?(machine, raise_error=false)
        return true #for now
       ## If the machine explicitly said SSHFS is not supported, then
       ## it isn't supported.
       #if !machine.config.nfs.functional
       #  return false
       #end
       #return true if machine.env.host.capability(:nfs_installed)
       #return false if !raise_error
       #raise Vagrant::Errors::NFSNotSupported
      end

      def prepare(machine, folders, opts)
        # Nothing is necessary to do before VM boot.
      end

      def enable(machine, folders, sshfsopts)
       #raise Vagrant::Errors::NFSNoHostIP if !nfsopts[:nfs_host_ip]
       #raise Vagrant::Errors::NFSNoGuestIP if !nfsopts[:nfs_machine_ip]

       #if machine.guest.capability?(:nfs_client_installed)
       #  installed = machine.guest.capability(:nfs_client_installed)
       #  if !installed
       #    can_install = machine.guest.capability?(:nfs_client_install)
       #    raise Vagrant::Errors::NFSClientNotInstalledInGuest if !can_install
       #    machine.ui.info I18n.t("vagrant.actions.vm.nfs.installing")
       #    machine.guest.capability(:nfs_client_install)
       #  end
       #end

        if machine.guest.capability?(:sshfs_installed)
          if !machine.guest.capability(:sshfs_installed)
            can_install = machine.guest.capability?(:sshfs_install)
            if !can_install
              raise Vagrant::Errors::SSHFSNotInstalledInGuest
            end
            machine.ui.info I18n.t("vagrant.actions.vm.sshfs.installing")
            machine.guest.capability(:sshfs_install)
          end
        end


        # Find out the host info and auth info for each folder
        folders.each do |id, opts|
          get_host_info(machine, opts)
          get_auth_info(machine, opts)
        end


        # Mount
       #machine.ui.info I18n.t("vagrant.actions.vm.nfs.mounting")
        folders.each do |id, opts|
            machine.guest.capability(:mount_sshfs_folder, opts)
        end
      end

      def cleanup(machine, opts)
      end

      protected

      def prepare_folder(machine, opts)
      end

      def get_host_info(machine, opts)
        # opts - the synced folder options hash
        # machine - 

        # If the synced folder entry doesn't have host information in it then
        # detect the vagrant host machine IP and use that
        if not opts.has_key?(:ssh_host) or not opts[:ssh_host]
            opts[:ssh_host] = detect_vagrant_host_ip(machine)
        end

        # If the synced folder doesn't have host port information in it 
        # default to port 22 for ssh
        # detect the vagrant host machine IP and use that
        if not opts.has_key?(:ssh_port) or not opts[:ssh_port]
            opts[:ssh_port] = '22'
        end
      end

      def detect_vagrant_host_ip(machine)
        # Only run detection if it hasn't been run before
        if not @@vagrant_host_machine_ip
          # Attempt to detect host machine IP by connecting over ssh
          # and then using the $SSH_CONNECTION env variable information to
          # determine the vagrant host IP address
          hostip = ''
          machine.communicate.execute('echo $SSH_CONNECTION') do |type, data|
            if type == :stdout
              hostip = data.split()[0]
            end
          end
          # TODO do some error checking here to make sure hostip was detected
          machine.ui.info("Detected host ip address is " + hostip)
          @@vagrant_host_machine_ip = hostip
        end
        # Return the detected host IP
        @@vagrant_host_machine_ip
      end

      def get_auth_info(machine, opts)
        # opts - the synced folder options hash
        # machine - 
        prompt_for_password = false
        ssh_info = machine.ssh_info

        # Detect the username of the current user
        username = `whoami`.strip

        # If no username provided then default to the current
        # user that is executing vagrant
          if not opts.has_key?(:ssh_username) or not opts[:ssh_username]
            opts[:ssh_username] = username
          end

        # Check to see if we need to prompt the user for a password.
        # We will prompt if:
        #  - User asked us to via prompt_for_password option
        #  - User did not provide a password in options and is not fwding ssh agent
        #
        if opts.has_key?(:prompt_for_password) and opts[:prompt_for_password]
            prompt_for_password = opts[:prompt_for_password]
        end
          if not opts.has_key?(:ssh_password) or not opts[:ssh_password]
            if not ssh_info.has_key?(:forward_agent) or not ssh_info[:forward_agent]
            prompt_for_password = true
            end 
          end

        # Now do the prompt
        if prompt_for_password
          opts[:ssh_password] = 
            machine.ui.ask("SSHFS Password for " + opts[:ssh_username] + ":", echo: false)
        end
      end
    end
  end
end
