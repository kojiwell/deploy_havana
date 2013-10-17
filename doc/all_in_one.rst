.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Build All-in-One Node Anyway.
=============================

Quick Installation by Bash Script
---------------------------------

First of all, you need to update ``/etc/hosts`` for your environment. If your hostname is not resolvable,
``nova-network`` fails to start.

Switch to ``root`` user, and download the bash script.::

   su - root
   git clone https://github.com/kjtanaka/havana_startup.git
   cd havana_startup

Create and modify your ``setuprc`` file, and execute ``build_all_in_one.sh``.
Two examples of ``setuprc`` are given below.::

   cp setuprc_example_[1NIC/2NICs] setuprc
   vi setuprc
   bash -ex build_all_in_one.sh

* `setuprc example for 2NICs <http://kjtanaka.github.io/havana_startup/setuprc_2nics.html>`_
* `setuprc example for 1NIC <http://kjtanaka.github.io/havana_startup/setuprc_1nic.html>`_

If the bash script finished fine, your machine would be rebooted at the end of the script. 
So wait until it becomes online.

Boot Your First Instance and Feel It
------------------------------------


