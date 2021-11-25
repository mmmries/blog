#!/bin/bash

# This script is used to remotely connect the server running in production
# It is based on https://raw.githubusercontent.com/fly-apps/hello_elixir/explicitly-set-release-cookie/observer

# After opening a Wireguard connection to your Fly network, run this script to
# open a BEAM Observer from your local machine to the remote server. This creates
# a local node that is clustered to a machine running on Fly.

# In order for it to work:
# - Your wireguard connection must be up.
# - The COOKIE value must be the same as the cookie value used for your project.
# - Observer needs to be working in your local environment. That requires WxWidget support in your Erlang install.

# When done, close Observer. It leaves you with an open IEx shell that is connected to the remote server. You can safely CTRL+C, CTRL+C to exit it.

# This needs to match the cookie in mix.exs under the releases section
COOKIE=7HdDx0YmOdv6YyBo_4UXC7n7vb5LiHTP13iXWh7GMjCUuM8apX9q7Q==

set -e

# Get the first IPv6 address returned
ip_array=( $(fly ips private | awk '(NR>1){ print $3 }') )
IP=${ip_array[0]}

# Get the Fly app name. Assumes it is used as part of the full node name
APP_NAME=`fly info --name`
FULL_NODE_NAME="${APP_NAME}@${IP}"
echo Attempting to connect to $FULL_NODE_NAME

# Export the BEAM settings for running the "iex" command.
# This creates a local node named "my_remote". The name used isn't important.
# The cookie must match the cookie used in your project so the two nodes can connect.
iex --erl "-proto_dist inet6_tcp" --sname my_remote --cookie ${COOKIE} -e "IO.inspect(Node.connect(:'${FULL_NODE_NAME}'), label: \"Node Connected?\"); IO.inspect(Node.list(), label: \"Connected Nodes\"); :observer.start"