#!/bin/bash
#
# pve-nag-buster.sh (v01) https://github.com/foundObjects/pve-nag-buster
# Copyright (C) 2019 /u/seaQueue (reddit.com/u/seaQueue)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

RELEASE=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release)
NAGTOKEN="data.status !== 'Active'"
NAGFILE="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

# disable license nag: https://johnscs.com/remove-proxmox51-subscription-notice/

if $(grep -q "$NAGTOKEN" "$NAGFILE") ; then
	echo "$0: Removing Nag ..."
	sed -i.orig "s/$NAGTOKEN/false/g" "$NAGFILE"
	systemctl restart pveproxy.service
fi

PAID_BASE="/etc/apt/sources.list.d/pve-enterprise"
FREE_LIST="/etc/apt/sources.list.d/pve-no-subscription.list"

# switch to pve-no-subscription repo

if [ -f "$PAID_BASE.list" ]; then
	echo "$0: Updating PVE repo lists ..."
	mv -f "$PAID_BASE.list" "$PAID_BASE.disabled"
	cat <<EOF>"$FREE_LIST"
# .list file automatically generated by $0 at $(date)
#
# Do not edit this file by hand, it will be overwritten
#

deb http://download.proxmox.com/debian/pve $RELEASE pve-no-subscription
EOF

fi
