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


require 'oni/oniclient'

include ONI::Client

# subscribe to service
oni_subscribe('guest', 'pass')

# talk to object 1
obj1 = oni_request(:Object1)
puts obj1.call_me('please', 'pretty please')

# talk to object 2
obj2 = oni_request(:Object2)
puts obj2.call_me('thanks', 'much thanks')

# unsubscribe from service
oni_unsubscribe
