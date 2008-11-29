# TomsLib - Tom's Ruby Support Library
# Example: ONI Client
# Copyright (c) 2002 Thomas Sawyer, Ruby License
#
# For purposes of this library a url is defined as both
# the typical idea of a url and a local filepath as well.

require 'thread'
require 'socket'


module TomsLib

  module ONI

    module Server
    
      def ONIServer.go(host='localhost', port=8080)
        server = TCPServer.new(host, port)
        while (session = server.accept)
          request = session.gets("\r")
          receiver, message, *args = request.strip.split("\f")
          begin
            result = @@members[receiver].send(message.intern, args)
          rescue ScriptError
            result = ''
          rescue StandardError
            result = ''
          ensure
            session.print result + "\r"
            session.close
          end
        end
      end
      
      def oniserver_join(name, object)
        @@members = {} if not Servlet.class_variables.include?('@@members')
        @@members[name] = object
      end
      
    end  # Server
    
    
    module Client

      def servlet_client_request(receiver, method, *args)
        begin
          client = nil
          timeout(1) do  # the server has one second to answer
            client = TCPSocket.new('localhost', '8080')
          end
        rescue
          puts "error: #{$!}"
        else
          request = "#{receiver}\f#{method}\f#{args.join("\f")}\r"
          client.send (request, 0)
          response = client.gets("\r")
          client.close
        end
        return response
      end
    
    end  # Client
    
  end  # ONI

end  # TomsLib





# Testing

class TestServlet
  
  include TomsLib::Servlet
  
  def initialize 
    servlet_join('testservlet1', self)
  end
  
  def sayhi(*args)
    return "Hi from Test Servlet 1 #{args.join(' ')}"
  end
  
end


class TestServlet2
  
  include TomsLib::Servlet
  
  def initialize 
    servlet_join('testservlet2', self)
  end
  
  def sayhi
    return "Hi from Test Servlet 2"
  end
  
end

TestServlet.new
TestServlet2.new

TomsLib::Servlet.serve

