# -*- mode: ruby -*-
# vi: set ft=ruby :


VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
  config.vm.box = "koalephant/debian12"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :vmware_desktop do |vmware|
    vmware.linked_clone = true
    vmware.allowlist_verified = true
    vmware.vmx["memsize"] = "2048"
    # vmware.vmx["ethernet0.pcislotnumber"] = "160"
  end

   # Application server 1.
   config.vm.define "london-1" do |app|
    app.vm.hostname = "london-11.test"
    app.vm.network "private_network", ip: "192.168.56.4"
  end

  # Application server 2.
  config.vm.define "london-2" do |app|
    app.vm.hostname = "london-2.test"
    app.vm.network "private_network", ip: "192.168.56.5"
  end

  
  config.vm.define "frankfurt" do |db|
    db.vm.hostname = "frankfurt.test"
    db.vm.network "private_network", ip: "192.168.56.7"
  end

  config.vm.define "seattle" do |db|
    db.vm.hostname = "seattle.test"
    db.vm.network "private_network", ip: "192.168.56.8"
  end

  config.vm.define "singapore" do |db|
    db.vm.hostname = "singapore.test"
    db.vm.network "private_network", ip: "192.168.56.9"
  end

  config.vm.provision :ansible do |ansible| 
    ansible.playbook = "playbook/site.yml"
    ansible.become = true 
    ansible.limit = "all"
    ansible.become_user = "root"
    ansible.compatibility_mode = "2.0"
    ansible.groups = {
      "k3s_cluster" => ["london-1", "london-2", "frankfurt", "seattle", "singapore"],
      "server" => ["london-1", "london-2", "frankfurt"],
      "agent" => ["seattle", "singapore"],
      "k3s_cluster:vars" => {
        ansible_port: 22,
        ansible_user: "root",
        k3s_version: "v1.26.9+k3s1",
        extra_server_args: "",
        extra_agent_args:"",
        token: "mytoken",
        api_endpoint: "{{ hostvars[groups['server'][0]]['ansible_host'] | default(groups['server'][0]) }}",
        pip_install_packages: ["pyyaml"],
        helm_version: "v3.14.3",
        api_port: 6443,
        k3s_server_location: "/var/lib/rancher/k3s",
        systemd_dir: "/etc/systemd/system",
      }
    }
  
    # ansible.galaxy_role_file = "requirements.yml"
  end


end
