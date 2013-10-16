OpenStack Havana Deployiment Scripts
=============

Not ready yet...


All in One
----------
```
   Public Network
  --------------------------------
      |                          
      | eth1 [xxx.xxx.xxx.xxx/24]
     -----------------           
    | All in One      |          
    | =============== |          
    | Keystone        |          
    | Glance          |          
    | Horizon         |          
    | Nova API        |          
    | Nova Scheduler  |          
    | Nova Compute    |          
    | Nova Network    |          
    | Nova Conductor  |          
     -----------------           
      | eth0 [xxx.xxx.xxx.xxx/24]
      |                          
  --------------------------------
   Internal/Admin Network
```

Multiple Compute Node
--------------------
```
   Public Network
  -------------------------------------------------------------------------
      |                                 |                                |
      | eth1 [xxx.xxx.xxx.xxx/24]       | eth1 [xxx.xxx.xxx.xxx/24]      |
     -----------------                 -----------------                ---
    | All in One      |               | Compute Node 01 |              |
    | =============== |               | =============== |              |
    | Keystone        |               | Nova Compute    |              |
    | Glance          |               | Nova Network    |              |
    | Horizon         |               |                 |              |
    | Nova API        |               |                 |              |
    | Nova Scheduler  |               |                 |              |
    | Nova Compute    |               |                 |              |
    | Nova Network    |               |                 |              |
    | Nova Conductor  |               |                 |              |
     -----------------                 -----------------                ---
      | eth0 [xxx.xxx.xxx.xxx/24]       | eth0 [xxx.xxx.xxx.xxx/24]      |
      |                                 |                                |
  -------------------------------------------------------------------------
   Internal/Admin Network
```
