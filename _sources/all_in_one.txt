.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Build All-in-One Node Anyway
=============================

Quick Installation by Bash Script
---------------------------------

First of all, you need to update ``/etc/hosts`` for your environment. If your hostname is not resolvable,
``nova-network`` fails to start.

Switch to ``root`` user, and download the bash script. ::

   su - root
   git clone https://github.com/kjtanaka/havana_startup.git
   cd havana_startup

Create and modify your ``setuprc`` file, and execute ``build_all_in_one.sh``.
Two examples of ``setuprc`` are given below. ::

   cp setuprc_example_[1NIC/2NICs] setuprc
   vi setuprc
   bash -ex build_all_in_one.sh

* `setuprc example for 2NICs <https://github.com/kjtanaka/havana_startup/blob/master/doc/setuprc_2nics.rst>`_
* `setuprc example for 1NIC <https://github.com/kjtanaka/havana_startup/blob/master/doc/setuprc_1nic.rst>`_

If the bash script finished fine, your machine would be rebooted at the end of the script. 
So wait until it becomes online.

Boot Your First Instance and Feel It
------------------------------------

Load nova environment. ::

   cd havana_startup
   source admin_credential

Check the list of images, flavors and keypairs. ::

   nova image-list
   nova flavor-list
   nova keypair-list

Boot your first instance. ::

   nova boot --image ubuntu-12.04 --flavor m1.small --key-name key1 vm001

Check the status of instance. ::

   nova list

Take a look at the console log. ::

   nova console-log vm001

If all look good, ssh to your vm001. ::

   ssh 192.168.201.3 -l ubuntu -i key1.pem
