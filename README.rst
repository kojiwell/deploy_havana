OpenStack Havana Agile Startup
==============================

This is about step-by-step startup of OpenStack Havana with Ubuntu 12.04 LTS. 

Goods and Bads about this approach
----------------------------------

* Goods
   * You can start with single node and scale it to some extent.
   * Each step makes something good, with a little effort.
* Bads
   * The document is ongoing and unfinished, and the scripts are beta forever.
   * Each step makes something good. However, going to the next step will make
     some additional work. For example, when you enable ssl on keystone later,
     you need to delete the keystone endpoint and relegister it with https.
   * Best-effort in a lot of ways.

Index
-----

**Day 1.** `Build all-in-one node anyway. <https://github.com/kjtanaka/havana_startup/blob/master/doc/all_in_one.rst>`_

**Day 2.** `Add Nova compute nodes. <https://github.com/kjtanaka/havana_startup/blob/master/doc/add_compute.rst>`_

**Day 3.** `Build Cinder volume nodes. <https://github.com/kjtanaka/havana_startup/blob/master/doc/add_volume.rst>`_

**Day 4.** Make Horizon WebUI Secure (enable SSL). [On The Way]

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
| **10/17/2013** Day 1 and Day 2 are ready.
| **10/18/2013** Day 3 is ready.

Change Log
----------
* The all-in-one bash script was originally written by Akira Yoshiyama-san, under Apache License 2.0, 
  for Folsom version.
    * The link to Akira's script is here. `<http://www.debian.or.jp/~yosshy/ubuntu-openstack/>`_
      You can find his Grizzly script as well. I like his script so much, and somehow
      I feel Zen between the lines.
* I forked it, and then
    * changed the messaging system from QPID to RabbitMQ.
    * added script for Cinder setting on Keystone.
    * made another script for adding more Nova compute nodes.
    * modified for Grizzly version.
    * modified for Havana version.
    * made a script for adding more Cinder volume nodes.

License
-------
* The scripts are developed under Apache License 2.0
* The document is written under Creative Commons Attribution 3.0 Unported License.

.. image:: http://i.creativecommons.org/l/by/3.0/88x31.png
   :target: http://creativecommons.org/licenses/by/3.0/
