# ONI - Object Network Interface
# Copyright (c) 2002 Thomas Sawyer, LGPL
#
# Example: ONI Client

# ONI is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# ONI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ONI; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


require 'oni/oni'

ONI::Peer.go(8081)

# subscribe to service
ONI::Peer.subscribe('127.0.0.1:8080', 'guest', '')

# talk to object 1
obj1 = Object1.oni_new('127.0.0.1:8080')
puts obj1.call_me('please', 'pretty please')

# talk to object 2
obj2 = Object2.oni_new('127.0.0.1:8080')
puts obj2.call_me('thanks', 'much thanks')

# unsubscribe from service
#puts oni_unsubscribe

