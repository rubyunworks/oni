# ONI - Object Network Interface
# Copyright (c) 2002 Thomas Sawyer, LGPL
#
# ONI::Client - Object Network Interface Client

# TomsLib is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# TomsLib is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with TomsLib; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


require 'timeout'
require 'socket'
require 'yaml'


module ONI

  module Client

    def oni_subscribe(username, password)
      request = { 'message' => 'subscribe',
                  'username' => username,
                  'password' => password
                }
      return @oni_session_id = oni_com(request)
    end


    def oni_unsubscribe
      request = { 'message' => 'unsubscribe',
                  'session_id' => @oni_session_id
                }
      return oni_com(request)
    end

    
    def oni_request(class_symbol, *args)
      request = { 'message' => 'request',
                  'session_id' => @oni_session_id,
                  'class_symbol' => class_symbol,
                  'args' => args
                }
      obj_hash = oni_com(request)
      return ONI_Object.new(obj_hash['object_id'], @oni_session_id, obj_hash['host'], obj_hash['port'])
    end

    private
    
    def oni_com(request)
      begin
        client = nil
        timeout(1) do  # the server has one second to answer
          client = TCPSocket.new('localhost', '8081')
        end
      rescue
        response = "#{$!}"
        puts "error: #{response}"
      else
        req = request.to_yaml
        client.write([req.size].pack('N') + req)
        response = client.read(client.read(4).unpack('N')[0])
        client.close
      end
      return YAML.load(response)
    end

  end  # Client
  
  
  class ONI_Object
  
    def initialize(object_id, session_id, host='localhost', port='8081')
      @object_id = object_id
      @session_id = session_id
      @host = host
      @port = port
    end
  
    def method_missing(method_symbol, *args)
      request = { 'message' => 'call',
                  'session_id' => @session_id, 
                  'object_id' => @object_id,
                  'method_symbol' => method_symbol,
                  'args' => args
                }
      return oni_com(request)
    end
  
    private
    
    def oni_com(request)
      begin
        client = nil
        timeout(1) do  # the server has one second to answer
          client = TCPSocket.new(@host, @port)
        end
      rescue
        response = "#{$!}"
        puts "error: #{response}"
      else
        req = request.to_yaml
        client.write([req.size].pack('N') + req)
        response = client.read(client.read(4).unpack('N')[0])
        client.close
      end
      return YAML.load(response)
    end
  
  end  # ONI_Object
  
end  # ONI

