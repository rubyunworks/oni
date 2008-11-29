# ONI - Object Network Interface
# Copyright (c) 2002 Thomas Sawyer, LGPL
#
# Example: ONI Server

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

module Services

  class Object1
    
    def initialize
    end
    
    def call_me(*args)
      return "Hi, from Object 1. You passed: #{args.join(', ')}"
    end
    
  end
  
  class Object2
    
    def initialize
    end
    
    def call_me(*args)
      return "Hi, from Object 2. You passed: #{args.join(', ')}"
    end
    
  end

end

ONI::Peer.go(8080, Services).join


