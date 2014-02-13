OpenStack Havana Startup
========================

This is about how to start OpenStack Havana in a small 
scale and grow it to some extent.

Build All-in-One Node to begin with
-----------------------------------

::

    Public Network
   +-------------------------------
       |                           
       | eth1 [xxx.xxx.xxx.xxx/24] 
     +-----------------+           
     | host01          |           
     | =============== |           
     | Keystone        |           
     | Glance          |           
     | Horizon         |          
     | Nova API        |          
     | Nova Scheduler  |          
     | Nova Compute    |
     | Nova Network    | 
     | Nova Conductor  |      
     +-----------------           
       | eth0 [xxx.xxx.xxx.xxx/24] 
       |                           
   +-------------------------------
    Internal/Admin Network

Quick Installation by Bash Script
---------------------------------

First of all, you need to update ``/etc/hosts`` for your environment. If your hostname is not resolvable,
``nova-network`` will fail to start.

Switch to ``root`` user, and download the bash script. ::

   sudo -i
   git clone https://github.com/kjtanaka/havana_startup.git
   cd havana_startup

Create and modify your ``setuprc`` file. Two examples of ``setuprc`` are given below. ::

   cp setuprc_example_[1NIC/2NICs] setuprc
   vi setuprc

* `setuprc example for 2NICs <https://github.com/kjtanaka/havana_startup/blob/master/doc/setuprc_2nics.rst>`_
* `setuprc example for 1NIC <https://github.com/kjtanaka/havana_startup/blob/master/doc/setuprc_1nic.rst>`_

Execute ``build_all_in_one.sh`` with ``-ex`` option. ::

   bash -ex build_all_in_one.sh

If the bash script finished fine, your machine would be rebooted at the end of the script. 
So wait until it becomes online.

Boot Your First Instance
------------------------

Load nova environment. ::

   cd havana_startup
   source admin_credential

Check the list of images, flavors and keypairs. ::

   nova image-list

   +--------------------------------------+--------------+--------+--------+
   | ID                                   | Name         | Status | Server |
   +--------------------------------------+--------------+--------+--------+
   | d95da7a5-d67d-4569-9edf-9524071b2c05 | ubuntu-12.04 | ACTIVE |        |
   +--------------------------------------+--------------+--------+--------+
   
::

   nova flavor-list

   +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
   | ID | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
   +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
   | 1  | m1.tiny   | 512       | 1    | 0         |      | 1     | 1.0         | True      |
   | 2  | m1.small  | 2048      | 20   | 0         |      | 1     | 1.0         | True      |
   | 3  | m1.medium | 4096      | 40   | 0         |      | 2     | 1.0         | True      |
   | 4  | m1.large  | 8192      | 80   | 0         |      | 4     | 1.0         | True      |
   | 5  | m1.xlarge | 16384     | 160  | 0         |      | 8     | 1.0         | True      |
   +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+

::

   nova keypair-list

   +------+-------------------------------------------------+
   | Name | Fingerprint                                     |
   +------+-------------------------------------------------+
   | key1 | xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx |
   +------+-------------------------------------------------+

Boot your first instance. ::

   nova boot --image ubuntu-12.04 --flavor m1.small --key-name key1 vm001

Check the status of instance. ::

   nova list

   +--------------------------------------+-------+--------+------------+-------------+-----------------------+
   | ID                                   | Name  | Status | Task State | Power State | Networks              |
   +--------------------------------------+-------+--------+------------+-------------+-----------------------+
   | a94c8354-b2fb-432e-8ff2-d98e30b50162 | vm001 | ACTIVE | None       | Running     | private=192.168.201.2 |
   +--------------------------------------+-------+--------+------------+-------------+-----------------------+

Take a look at the console log. ::

   nova console-log vm001

If all look good, you should be able to ssh to your first instance. ::

   ssh -i key1.pem ubuntu@192.168.201.2


Next things to do
-----------------

**1.** `Add Nova compute nodes. <https://github.com/kjtanaka/havana_startup/blob/master/doc/add_compute.rst>`_

**2.** `Build Cinder volume nodes. <https://github.com/kjtanaka/havana_startup/blob/master/doc/add_volume.rst>`_

**3.** `Enable SSL on Keystone and Horizon. <https://github.com/kjtanaka/havana_startup/blob/master/doc/ca_setup.rst>`_

**4.** Build Swift [On The Way]

**5.** Setup Swift as the backend storage of Glance [OTW]

**6.** Better understand Open vSwitch before Neutron [OTW]

**7.** Setup Neutron. [OTW]

Updates
----
| **10/17/2013** Day 1 and Day 2 are ready to try.
| **10/18/2013** Day 3 is ready to try.
| **10/28/2013** Day 4 is ready to try.

Script Change Log
----------
* The all-in-one bash script was originally written by Akira Yoshiyama-san, under Apache License 2.0. It was
  for Folsom version when I forked it. The link to Yoshiyama-san's script is here 
  `<http://www.debian.or.jp/~yosshy/ubuntu-openstack/>`_.
  You can find his Grizzly script as well. I like his script so much. I feel Zen between his lines.
* I forked Yoshiyama-san's script, and then
    * changed the messaging system from QPID to RabbitMQ.
    * added script for Cinder setting on Keystone.
    * made another script for adding more Nova compute nodes.
    * modified for Grizzly version.
    * modified for Havana version.
    * made a script for adding more Cinder volume nodes.
    * Made a script for Keystone's SSL setting.

License
-------
* The scripts are developed under Apache License 2.0 as you can see on the change log.
* The document is written under Creative Commons Attribution 3.0 Unported License.

.. image:: http://i.creativecommons.org/l/by/3.0/88x31.png
   :target: http://creativecommons.org/licenses/by/3.0/
