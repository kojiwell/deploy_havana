OpenStack Havana Agile Startup
==============================

Step-by-step agile startup of OpenStack Havana with Ubuntu 12.04 LTS.

**Day 1.** `Build all-in-one node anyway. <https://github.com/kjtanaka/havana_startup/blob/master/doc/all_in_one.rst>`_

**Day 2.** `Add some more Nova compute nodes. <https://github.com/kjtanaka/havana_startup/blob/master/doc/add_compute.rst>`_

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

Script Change Log
-----------------
* The all-in-one bash script was originally written by Akira Yoshiyama, under Apache License 2.0, 
  as a single node installation for beginers to try Folsom version.
* I forked it and,
** Changed the messaging system from QPID to RabbitMQ.
** Added script for Cinder configration.
** Made another script for adding more Nova compute nodes.
** Modified for Grizzly version.
** Modified for Havana version.
