---
title = "Getting Started With the Sprinkler Project"
tags = ["elixir", "nerves", "sprinkler", "meetup"]
---

The [Nerves Remote Meetup](https://twitter.com/NervesMeetup) is kicking off this coming Wednesday.
When I was going through the process of getting my Raspberry Pi setup with a basic Nerves project I was impressed with how simple it was to get a really good development setup going.
This post will walk through getting a basic nerves project up and running on a Raspberry Pi 3.

## Getting Started

Run through the [Nerves Installation Guide](https://hexdocs.pm/nerves/installation.html) to make sure you have the right dependencies setup.
Initialize a nerves project with a command like: `mix nerves.new sprinkler`.
Now are going to add `nerves_init_gadget` and customize some configuration.
You can see the [full diff here for reference](https://github.com/mmmries/sprinkler/compare/db25c00ced4eb1a627373c2b2229df67ac303887...bab60a8947c9142ef5987b1a0c86003eb320403b).

We start by adding `{:nerves_init_gadget, "~> 0.4"}` to our target deps and add `:nerves_init_gadget` the init list of `shoehorn` in our `config/config.exs` file.
At the bottom of our `config/config.exs` we add some configuration that will load our existing public ssh key to make that an authorized key for our device

```elixir
config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!(), ".ssh/id_rsa.pub"))
  ]
```

We get SSH security on our device!
Next we add some configuration to store `Logger` entries into [RingLogger](https://hex.pm/packages/ring_logger).
This will keep the last few hundred `Logger` entries in memory so we can check the log even if we weren't connected the device when it got logged.

```
config :logger, backends: [RingLogger]
```

Now we add configuration for the `:nerves_init_gadget` library to specify the DNS name of our device, tell it which network interface to watch and tell it to give us an ssh terminal port.

```elixir
config :nerves_init_gadget,
  ifname: "wlan0",
  address_method: :dhcp,
  mdns_domain: "sprinkler.local",
  node_name: "sprinkler",
  node_host: :mdns_domain,
  ssh_console_port: 22
```

And finally we add configuration for how to connect to the WiFi.
We use environment variables to set the WiFi ssid and passkey.
You'll notice that we set these in our commands to build and push firmware images.

```elixir
key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"
 config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("NERVES_NETWORK_SSID"),
    psk: System.get_env("NERVES_NETWORK_PSK"),
    key_mgmt: String.to_atom(key_mgmt)
  ]
```

## Burn The Initial Image

Mount your MicroSD card to the host machine and run a command like:

```shell
MIX_TARGET=rpi3 NERVES_NETWORK_SSID=MyWiFi NERVES_NETWORK_PSK=MyPassword mix do deps.get, firmware, firmware.burn
```

Confirm that it's burning to the correct disk and follow the prompts to burn the image.
Now put the MicroSD into your raspberry pi 3 and power it up.

## Testing The Initial Setup

Within a few seconds you should be able to run `ping sprinkler.local` from your host machine and see that it gets ping results back.
You can further test it by running `ssh sprinkler.local` and you should have an IEx terminal.
Try running `RingLogger.tail()` in that IEx session and you should see the recent log entries probably related to bootup, WiFi or DNS updates.
To exit the ssh session you'll need to hit enter a few times and then type `~.`.

Finally let's make sure we can get another node connected to it.
Run `cat rel/vm.args` and copy the `cookie` value.
Now on your host machine run `iex --cookie PASTE_YOUR_COOKIE_VALUE_HERE --name iex@host.local`.
In your new IEx session type `Node.ping(:"sprinkler@sprinkler.local")` and you should get back `:pong`.
Run `:observer.start()` to open the observer.
In your observer window you can select open the "Node" menu item and select "sprinkler@sprinkler.local".
Now you are seeing memory, CPU and other information from your device.

## What We Have So Far?

We now have a device running a custom firmware image that support MDNS for easy discovery, ssh for secure terminal access, and erlang distribution so that we can easily have it coordinate with other programs.
This is a powerful set of features, but we aren't quite done yet.
When we want to update our program it will be a pain to constantly power-off the device, take out the SD card, burn a new image and then reboot the device.

Luckily the `nerves_init_gadget` package also makes it possible to securely push firmware updates over-the-wire.
😍😍😍😍😍😍😍😍😍😍😍

## The Next Feature

It would be really nice to be able to visually tell if our device is running our code.
The Raspberry Pi 3 we are using has a status LED built into it which normally blinks based on disk activity.
We are going to take control of that LED and make it blink a recognizable pattern.
So whenever our code boots and runs properly we'll be able to see that pattern and know that the device is up and running.

You can see [the full diff here for reference](https://github.com/mmmries/sprinkler/compare/f41372254cea1058e8873cfe4b19987ab1f59d12...efd379ff3b3687c13b8b000c99a8fc3d1b9ac71e).

We start by adding `{:nerves_leds, "~> 0.8"}` to our target deps.
Then in our `config/config.exs` file we add some configuration to give our status led the name `:status`.

```elixir
config :nerves_leds, names: [status: "led0"]
```

While we are in the file we are also going to tell [shoehorn](https://hex.pm/packages/shoehorn) that it needs to start `:runtime_tools` and `:nerves_leds` at boot time.

```elixir
config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget, :runtime_tools, :nerves_leds],
  app: Mix.Project.config()[:app]
```

Now we need a process that will periodically call `Nerves.Leds.set` so we can change the `:status` LED to be off and on.
We write a small [GenServer](https://hexdocs.pm/elixir/1.6.6/GenServer.html) to handle this.
See the `lib/sprinkler/blinky.ex` file in the diff link above for details.
Then in our `lib/sprinkler/application.ex` file we add this process to our supervision tree like this:

```elixir
  def children(_target) do
    [
      {Sprinkler.Blinky, nil}
    ]
  end
```

Now when our application starts up it will call `Sprinkler.Blinky.start_child(nil)` and supervise the `pid` that is returned.

## Push The Feature to the Device

We can build the firmware image and push it to our device with a single command.

```shell
MIX_TARGET=rpi3 NERVES_NETWORK_SSID=MyWiFi NERVES_NETWORK_PSK=MyPassword mix do deps.get, firmware, firmware.push sprinkler.local
```

This command will take a little while to complete and at the end of it your terminal should say something like:

```
Success!
Elapsed time: 7.232 s
Rebooting...
```

If you are looking at your device you will see the red power LED turn off, then turn back on.
The green LED will blink rapidly while the device is going through the linux boot process, reading things off disk etc.
But once your code finishes booting you should see the green LED start a pattern of 2 seconds off, 1 second blinking.
If you start another observer session like we did above you will be able to see that the `sprinkler` application is running and is supervising the `Sprinkler.Blinky` process 🎉.

## Wrapping Up

This is a pretty incredible set of features to start a project with.
We have a device that can:

* join our WiFi automatically
* makes itself discoverable
* has a secure remote shell access
* secure remote update
* erlang distribution
  * ability to introspect any of the processes and send them messages at any time
  * we can use observer to get memory, CPU and other stats
* based on linux
  * really great hardware support
  * a ton of standard C and elixir libraries to use

I've been playing around with embedded devices for fun since ~2000.
None of the other devices or methods that I've ever used had any of the features above.
Each time I wanted to test them I had to run a propietary IDE on my host machine, connect with a proprietary programming cable and write a custom subset of C to get anything done.
Nerves provides a really amazing platform to skip most of the annoying bits of embedded programming and get down to features right away.
