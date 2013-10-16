.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Build All-in-One Node Anyway.
==========================================================

Quick Install by a Bash Script.
------------

First, you need to update ``/etc/hosts`` for your environment. If your hostname is not resolvable,
``nova-network`` fails to start.

Switch to ``root`` user, and download the installation scripts.::

   su - root
   git clone https://github.com/kjtanaka/deploy_havana.git
   cd deploy_havana

Create your ``setuprc`` file and modify it for your environment, and execute
``build_all_in_one.sh``. Some examples of ``setuprc`` are given below.::

   cp setuprc_example_[1NIC/2NICs] setuprc
   vi setuprc
   bash -ex build_all_in_one.sh

If everything's went fine, the machine would be rebooted at the end of the script. Examples of ``setuprc`` are given below.

* `setuprc example for 2NICs <http://kjtanaka.github.io/deploy_havana/setuprc_2nics.html>`_
* `setuprc example for 1NIC <http://kjtanaka.github.io/deploy_havana/setuprc_1nic.html>`_

