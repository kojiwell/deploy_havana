.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Enable SSL on Keystone and Horizon
==========================================================

When you enable SSL, the common name is the important thing.
Which should be Hostname + Domain Name like ``keystone.yoursite.org``.
You should be able to reach the host from anywhere with its common name.

The script ``ca_setup.sh`` does the lavor work for you. 
So, login to your management nost and setup ``COMMON_NAME`` on setuprc, 
and execute the script like this. ::

   cd havana_startup
   echo COMMON_NAME=keystone.yoursite.com >> setuprc
   bash -ex ca_setup.sh

If the bash script finshed fine, you can try the follows.

Use client of Keystone, Nova and Glance
---------------------------------------

Setup your OpenStack environment and try some commands ::

   cd havana_startup
   source admin_credential
   keystone endpoint-list
   nova list
   glance image-list

Use Horizon with https
----------------------

Try `<https://keystone.yoursite.com/horizon`_ .

