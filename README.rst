OpenStack Havana Agile Startup
==============================

This is about step-by-step startup of OpenStack Havana with Ubuntu 12.04 LTS. 

Goods and Bads
--------------

* Goods
   * You can start with single node and scale it to some extent.
   * Each step makes something good, with a little effort.
* Bads
   * The document is unfinished, and the scripts are beta forever.
   * Each step makes something good. However, going to the next step will make
     some additional work. For example, when you enable ssl on keystone later,
     you need to delete the keystone endpoint and relegister it with https.
   * Best-effort in a lot of ways.

Logbook
-------

**Day 1.** `Build all-in-one node anyway. <https://github.com/kjtanaka/havana_startup/blob/master/doc/all_in_one.rst>`_

**Day 2.** `Add Nova compute nodes. <https://github.com/kjtanaka/havana_startup/blob/master/doc/add_compute.rst>`_

**Day 3.** Build Cinder volume nodes. [On The Way]

**Day 4.** Make Horizon WebUI Secure (enable SSL). [OTW]

**Day 5.** Make Keystone Secure (enable SSL). [OTW]

**Day 6.** Build Swift [OTW]

**Day 7.** Setup Swift as the backend storage of Glance [OTW]

**Day 8.** Better understand Open vSwitch before Neutron [OTW]

**Day 9.** Setup Neutron. [OTW]

Sphinx Doc
----------
The Sphinx Doc is here `<http://kjtanaka.github.io/havana_startup/>`_. Which is the same as above, 
but probably looks better organized.

News
----
**10/17/2013** Day 1 and Day 2 are ready.

Change Log
----------
* The all-in-one bash script was originally written by Akira Yoshiyama, under Apache License 2.0, 
  for Folsom version.
* I forked it, and then
    * changed the messaging system from QPID to RabbitMQ.
    * added script for Cinder setting on Keystone.
    * made another script for adding more Nova compute nodes.
    * modified for Grizzly version.
    * modified for Havana version.
