# ONI - Object Network Interface
# Copyright (c) 2002 Thomas Sawyer, LGPL
#
# ONI::Server - Object Network Interface Server

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

  EOT = "\004"

  module Server
  
    def Server.go(host='localhost', port=8081)
      @@oni_sessions = {}
      @@oni_object_pool = {}
      server = TCPServer.new(host, port)
      while (session = server.accept)
        result = "\a".to_yaml
        raw_request = session.read(session.read(4).unpack('N')[0]) #.gets(EOT)
        raw_request.chomp!(EOT)
        request = YAML::load(raw_request)
        begin
          message = request['message'].to_s
          case message
          when 'subscribe'
            username = request['username'].to_s
            password = request['password'].to_s
            result = Server.join(username, password)
          when 'unsubscribe'
            session_id = request['session_id']
            result = Server.drop(session_id)
          when 'request'
            session_id = request['session_id']
            class_symbol = request['class_symbol']
            args = request['args'].to_a
            if @@oni_sessions.include?(session_id)
              obj = const_get(class_symbol).new(*args)
              obj_id = obj.id
              @@oni_object_pool[session_id][obj_id] = obj
              result = { 'object_id' => obj_id, 'host' => host, 'port' => port }
            end
          when 'call'
            session_id = request['session_id']
            object_id = request['object_id']
            method_symbol = request['method_symbol']
            args = request['args'].to_a
            result = @@oni_object_pool[session_id][object_id].send(method_symbol, *args)
          else
            result = "\aunknown service"
          end
        #rescue ScriptError => err
          #result = "\a#{err}".to_yaml
        #rescue StandardError => err
          #result = "\a#{err}".to_yaml
        ensure
          res = result.to_yaml
          session.write([res.size].pack('N') + res) #print(result.to_yaml + EOT)
          session.close
        end
      end
    end
    
    def Server.validate(username, password)
      return true
    end
    
    def Server.join(username, password)
      if Server.validate(username, password)
        session_id = "#{@@oni_sessions.length}#{username}"
        @@oni_sessions[session_id] = true
        @@oni_object_pool[session_id] = {}
        return session_id
      else
        return "\ainvalid identity"
      end
    end

    def Server.drop(session_id)
      if @@oni_sessions.include?(session_id)
        @@oni_sessions.delete(session_id)
        return true
      else
        return "\anot subscribed"
      end
    end

  end  # Server
    
end  # ONI
