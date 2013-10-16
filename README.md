OpenStack Havana Deployiment Scripts
=============

Not ready yet...

```
   Public Network
  ------------------------------------------------------------------
      |                                 |
      | eth1 [xxx.xxx.xxx.xxx/24]       | eth1 [xxx.xxx.xxx.xxx/24]
     -----------------                 -----------------
    | All in One      |               | Compute Node    |
    | =============== |               | =============== |
    | Keystone        |               | Nova Compute    |
    | Glance          |               | Nova Network    |
    | Horizon         |               |                 |
    | Nova API        |               |                 |
    | Nova Scheduler  |               |                 |
    | Nova Compute    |               |                 |
    | Nova Network    |               |                 |
    | Nova Conductor  |               |                 |
     -----------------                 -----------------
      | eth0 [xxx.xxx.xxx.xxx/24]       | eth0 [xxx.xxx.xxx.xxx/24] 
      |                                 |
  ------------------------------------------------------------------
   Internal/Admin Network
```
