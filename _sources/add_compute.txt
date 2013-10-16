.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Add Compute Node
==========================================================

This is a test.test.::

    Public Network
   +--------------------------------------------------------------------------
       |                                 |                                |
       | eth1 [xxx.xxx.xxx.xxx/24]       | eth1 [xxx.xxx.xxx.xxx/24]      |
     +-----------------+               +-----------------+              +-----
     | All in One      |               | Compute Node 01 |              |
     | =============== |               | =============== |              |
     | Keystone        |               | Nova Compute    |              |
     | Glance          |               | Nova Network    |              |
     | Horizon         |               |                 |              |
     | Nova API        |               |                 |              |
     | Nova Scheduler  |               |                 |              |
     | Nova Compute <----[disable]     |                 |              |
     | Nova Network    |               |                 |              |
     | Nova Conductor  |               |                 |              |
     +-----------------                 -----------------               +-----
       | eth0 [xxx.xxx.xxx.xxx/24]       | eth0 [xxx.xxx.xxx.xxx/24]      |
       |                                 |                                |
   +--------------------------------------------------------------------------
    Internal/Admin Network

Test
