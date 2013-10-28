OpenStack Havana Agile Startup
==============================

OpenStack has high-scalability. So why don't we start with a single node, 
heading toward a right scale for each? So this is about a step-by-step 
startup of OpenStack Havana with Ubuntu 12.04 LTS. 

Goods and Bads about this approach
----------------------------------

* Goods
   * You can start with single node, which should be the easiest, and then scale it 
     to some extent with adding nodes and components.
   * The Bash scripts helps you to reduce manual works.
   * Each step makes something workable, with a little more effort.
   * Debug is relatively easy because you know it was working at the previous step.
* Bads
   * The document is ongoing and unfinished, and the scripts are beta forever.
     I often update things right now.
   * Each step makes something good. However, going to the next step will make
     some extra work for reconfiguration. For example, when you enable 
     ssl on keystone later, you need to delete the keystone endpoint and 
     relegister it with https. This kind of work happens at each step.
   * Best-effort in a lot of ways.

Index
-----

**Day 1.** `Build all-in-one node anyway. <https://github.com/kjtanaka/havana_startup/blob/master/doc/all_in_one.rst>`_

**Day 2.** `Add Nova compute nodes. <https://github.com/kjtanaka/havana_startup/blob/master/doc/add_compute.rst>`_

**Day 3.** `Build Cinder volume nodes. <https://github.com/kjtanaka/havana_startup/blob/master/doc/add_volume.rst>`_

**Day 4.** `Make Keystone and Horizon Secure. <https://github.com/kjtanaka/havana_startup/blob/master/doc/ca_setup.rst>`_

**Day 5.** Build Swift [OTW]

**Day 6.** Setup Swift as the backend storage of Glance [OTW]

**Day 7.** Better understand Open vSwitch before Neutron [OTW]

**Day 8.** Setup Neutron. [OTW]

News
----
| **10/17/2013** Day 1 and Day 2 are ready to try.
| **10/18/2013** Day 3 is ready to try.
| **10/28/2013** Day 4 is ready to try.

Change Log
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

License
-------
* The scripts are developed under Apache License 2.0 as you can see on the change log.
* The document is written under Creative Commons Attribution 3.0 Unported License.

.. image:: http://i.creativecommons.org/l/by/3.0/88x31.png
   :target: http://creativecommons.org/licenses/by/3.0/
