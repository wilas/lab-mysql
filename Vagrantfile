# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  
  config.vm.define :mammoth01 do |db_config|  
    vm_name= "mammoth01"
    db_config.vm.box = "SL64_box"
    db_config.vm.host_name = "#{vm_name}.farm"
    db_config.vm.customize ["modifyvm", :id, "--memory", "512", "--name", "#{vm_name}"]
  
    db_config.vm.network :hostonly, "77.77.77.151"
    db_config.vm.share_folder "v-root", "/vagrant", "."

    db_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "mammoth-master.pp"
        puppet.module_path = "modules"
    end
  end
  
  config.vm.define :mammoth02 do |db_config|  
    vm_name= "mammoth02"
    db_config.vm.box = "SL64_box"
    db_config.vm.host_name = "#{vm_name}.farm"
    db_config.vm.customize ["modifyvm", :id, "--memory", "512", "--name", "#{vm_name}"]
  
    db_config.vm.network :hostonly, "77.77.77.152"
    db_config.vm.share_folder "v-root", "/vagrant", "."

    db_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "mammoth-slave.pp"
        puppet.module_path = "modules"
    end
  end
  
  config.vm.define :logm do |db_config|  
    vm_name= "logm"
    db_config.vm.box = "SL64_box"
    db_config.vm.host_name = "#{vm_name}.farm"
    db_config.vm.customize ["modifyvm", :id, "--memory", "512", "--name", "#{vm_name}"]
  
    db_config.vm.network :hostonly, "77.77.77.161"
    db_config.vm.share_folder "v-root", "/vagrant", "."

    db_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "logm.pp"
        puppet.module_path = "modules"
    end
  end

end
