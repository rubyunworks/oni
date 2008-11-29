# TomsLib - Tom's Ruby Support Library
# Copyright (c) 2002 Thomas Sawyer, LGPL
#
# ONI - Object Network Interface

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


module TomsLib

  module ONI

    EOM = "\r"

    module Server
    
      def Server.go(state, host='localhost', port=8080)
        @@members = {}
        @@state = state
        server = TCPServer.new(host, port)
        while (session = server.accept)
          y_request = session.gets(EOM)
          request = Marshal.load(y_request)
          begin
            member = request[:member].to_s
            receiver = request[:receiver].to_s
            message = request[:message].to_s
            args = request[:args].to_a
            if receiver == 'ONI'
              case message
              when 'subscribe'
                if not @@members.include?(member)
                  Server.join(member, args)
                end
                result = Marshal.dump('subscribed')
              when 'unsubscribe'
                if @@members.include?(member)
                  Server.drop(member, args)
                end
                result = Marshal.dump('unsubsribed')
              else
                result = Marshal.dump('unknown ONI service request')
              end
            else
              result = Marshal.dump(@@members[member][receiver].send(message.intern, *args))
            end
          rescue ScriptError => err
            result = Marshal.dump("\a#{err}")
          rescue StandardError => err
            result = Marshal.dump("\a#{err}")
          ensure
            session.print(result + EOM)
            session.close
          end
        end
      end
      
      def Server.join(member, *args)
        @@members[member] = @@state.call
      end

      def Server.drop(member, *args)
        @@members.delete(member)
      end

    end  # Server
    
    
    module Client

      def oni_client_subscribe(membername)
        @membername = membername
        begin
          client = nil
          timeout(2) do  # the server has two seconds to answer
            client = TCPSocket.new('localhost', '8080')
          end
        rescue
          response = "#{$!}"
          puts "error: #{response}"
        else
          request = Marshal.dump({ :member => @membername, :receiver => 'ONI', :message => 'subscribe' }) + EOM
          client.send (request, 0)
          response = client.gets(EOM)
          client.close
        end
        return Marshal.load(response)
      end


      def oni_client_unsubscribe
        begin
          client = nil
          timeout(1) do  # the server has one second to answer
            client = TCPSocket.new('localhost', '8080')
          end
        rescue
          response = "#{$!}"
          puts "error: #{response}"
        else
          request = Marshal.dump({ :member => @membername, :receiver => 'ONI', :message => 'unsubscribe' }) + EOM
          client.send (request, 0)
          response = client.gets(EOM)
          client.close
        end
        return Marshal.load(response)
      end


      def oni_client_request(receiver, method_id, *args)
        begin
          client = nil
          timeout(1) do  # the server has one second to answer
            client = TCPSocket.new('localhost', '8080')
          end
        rescue
          response = "#{$!}"
          puts "error: #{response}"
        else
          request = Marshal.dump({ :member => @membername, :receiver => receiver, :message => method_id, :args => args }) + EOM
          client.send (request, 0)
          response = client.gets(EOM)
          client.close
        end
        return Marshal.load(response)
      end

    end  # Client
    
  end  # ONI

end  # TomsLib
