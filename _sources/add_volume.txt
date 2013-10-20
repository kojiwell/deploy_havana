.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Add Cinder Volume Nodes
==========================================================

::

    Public Network
   +--------------------------------------------------------------------------
       |                    |                                |
       |                    | eth1 [xxx.xxx.xxx.xxx/24]      |
   +------+               +-----------------+              +-----------------+
          |               | host03          |              |                 |
          |               | =============== |              |                 |
          |               | Cinder Volume   |              |                 |
          |               |                 |              |                 |
          |               |                 |              |                 |
          |               |                 |              |                 |
          |               |                 |              |                 |
          |               |                 |              |                 |
          |               |                 |              |                 |
          |               |                 |              |                 |
   +------+               +-----------------+              +-----------------+
       |                    | eth0 [xxx.xxx.xxx.xxx/24]      |
       |                    |                                |
   +--------------------------------------------------------------------------
    Internal/Admin Network

First, update ``/etc/hosts`` if needed, and copy it and your ``havana_startup``
directory to the Cinder Volume node(host03 in this example). ::

   scp /etc/hosts host03:/etc/hosts
   scp -r havana_startup host03:havana_startup

Login to host03 and set your cinder-volume partition on ``setuprc``.
In this example ``/dev/sdb1`` is the Cinder Volume. ::

   ssh host03
   cd havana_startup
   echo CINDER_VOLUME=/dev/sdb1 >> setuprc

Execute ``add_cinder_volume.sh`` with ``-ex`` option ::

   bash -ex add_nova_compute.sh

If the bash script finshed fine, Cinder Volume should be ready.

Create and attach a volume
---------------------------

Go back to host01(Management Host), and execute this. ::

   cinder-manage service list

   Binary           Host                                 Zone             Status     State Updated At
   cinder-scheduler host01                               nova             enabled    :-)   2013-10-18 05:49:18
   cinder-volume    host03                               nova             enabled    :-)   2013-10-18 05:49:19

If ``cinder-volume`` is ``:-)``, the volume node is running ok. 
So create a volume. ::

   source havana_startup/admin_credential
   nova volume-create 10 --display-name vol10G
   nova volume-list
   
   +--------------------------------------+-----------+--------------+------+-------------+-------------+
   | ID                                   | Status    | Display Name | Size | Volume Type | Attached to |
   +--------------------------------------+-----------+--------------+------+-------------+-------------+
   | 35d5f008-f252-4e5d-b8dd-cf34dc149d5b | available | vol10G       | 10   | None        |             |
   +--------------------------------------+-----------+--------------+------+-------------+-------------+

Attach it to an instance(vm001 as this example). ::

   nova volume-attach vm001 35d5f008-f252-4e5d-b8dd-cf34dc149d5b /dev/vdb
   ssh -l ubuntu -i key1.pem 192.168.201.3
   sudo fdisk -l

::

   Disk /dev/vda: 21.5 GB, 21474836480 bytes
   4 heads, 32 sectors/track, 327680 cylinders, total 41943040 sectors
   Units = sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disk identifier: 0x00015473

      Device Boot      Start         End      Blocks   Id  System
   /dev/vda1   *        2048    41943039    20970496   83  Linux

   Disk /dev/vdb: 10.7 GB, 10737418240 bytes
   16 heads, 63 sectors/track, 20805 cylinders, total 20971520 sectors
   Units = sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disk identifier: 0x00000000

   Disk /dev/vdb doesn't contain a valid partition table

Add more Cinder Volume Nodes as needed.
