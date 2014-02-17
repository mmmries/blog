---
layout: post
title: "Maglev on AWS t1.micro"
date: 2014-02-16 10:23
comments: true
categories: ruby maglev aws
---

## TL/DR; If you want to run maglev on a small AWS instance you probably need to reduce the shared page cache size. Try adjusting the SHR_PAGE_CACHE_SIZE_KB setting in system.conf

## The Problem
[Maglev](http://maglev.github.io/) is really awesome and I want to make a few toy apps and host them on my t1.micro AWS instance.

When I did a vanilla RVM install of maglev head I got a bunch of output that ended with this:

```
startstone[Info]: Starting Stone repository monitor 'maglev'.

startstone[Error]: Stone process (id=12577) has died.
startstone[Error]: Examine '/usr/local/rvm/rubies/maglev-head/log/maglev/maglev.log' for more information.  Excerpt follows:
```

The logfile it pointed me to contained this little nuggest:

```
 The stone was unable to start a cache page server on host '<stone's host>'.
Reason:  connect to cache monitor failed.
  Monitor process (8207) did not start.
```

There was an additional log file in the same directoy called maglev_8207pcmon.log which said:

```bash /usr/local/rvm/rubies/maglev-head/log/maglev/maglev_8207pcmon.log
...
 _____________________________________________________________________________
|   GEMSTONE_GLOBAL_DIR = /usr/local/rvm/rubies/maglev-head                   |
|_____________________________________________________________________________|
|   GemStone could not retrieve the IPC identifier associated with the memory |
|   key 1778474068.  shmget() error = errno=22,EINVAL, Invalid argument (programmer
| error).                                                                     |
|                                                                             |
  GemStone could not attach to the shared page cache.

  [SpcMon trace]: ... cache creation failed ...
  [SpcMon trace]: ... if the errno is (EINVAL) it is likely because the
                      cache size is less than the operating system imposed
                      minimum or greater than the operating system maximum.
--- 02/15/14 05:34:54.982 UTC :Starting shrpcmonitor shutdown
--- 02/15/14 05:34:54.982 UTC :Waiting for crashed slot recovery thread to shutdown...Done.
--- 02/15/14 05:34:54.982 UTC :Waiting for clean slot recovery thread to shutdown...Done.
--- 02/15/14 05:34:54.982 UTC :Waiting for stats thread to shutdown...Done.
--- 02/15/14 05:34:54.982 UTC :All threads have stopped.
  The Shared Page Cache Monitor is shutting down.
```

## From a Yak to a Solution

A little bit of googling led me to [a Gemstone/S article](http://programminggems.wordpress.com/2012/04/06/configuring-shared-memory/) which explained a bit about the shared memory, but in this case the maglev installer had set all the correct values for shared memory settings and the stone was still failing to start. So I checked the system.conf file for maglev which included the SHR_PAGE_CACHE_SIZE_KB setting. It was defaulted to ~1GB of shared memory, but a t1.micro has less than 600MB so I changed the setting like this:

```text /usr/local/rvm/rubies/maglev-head/etc/system.conf
#SHR_PAGE_CACHE_SIZE_KB = 1000000;
SHR_PAGE_CACHE_SIZE_KB = 307200;
```

Now maglev starts with a happy little success message.
