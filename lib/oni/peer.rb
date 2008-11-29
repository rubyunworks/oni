# ONI - Object Network Interface
# Copyright (c) 2002 Thomas Sawyer, LGPL

require 'yaml'
require 'timeout'
require 'socket'

$topbinding = binding

module ONI

  # ONI::Peer - Object Network Interface Peer

  module Peer

    def Peer.peer
      return "#{@@host}:#{@@port}"
    end

    
    def Peer.port
      return @@port.to_i
    end
    

    def Peer.go(port=8080, service_module=nil)
    
      @@host = IPSocket.getaddress(Socket.gethostname)  # get local machine's ip address
      @@port = port.to_i
      @@service_module = service_module
      
      @@sessions = {}
      @@pool = {}
      
      server = TCPServer.new(@@host, @@port)
      
      trap("INT") {
        puts "shutting down..."
        server.close
      }
      
      t = Thread.new {
        while(accept_session = server.accept)
          Thread.new(accept_session) { |session|
            yam_size = session.read(4).unpack("N")[0]
            yam = session.read(yam_size)
            msg = YAML.load(yam)
            puts ":: #{msg.inspect}" if $DEBUG
            case msg['REQ'].downcase
            when 'subscribe'
              res = Peer.remote_subscribe(msg['UID'], msg['PWD'])
            when 'unsubscribe'
              res = Peer.remote_unsubscribe(msg['SID'])
            when 'new'
              res = Peer.remote_new(msg['CID'], msg['ARG'])
            when 'call'
              res = Peer.remote_call(msg['OID'], msg['MID'], msg['ARG'])
            end
            yres = res.to_yaml
            yres_size = yres.size
            session.write([yres_size].pack("N") + yres)
          }
        end
      }
      
      puts "ONI Service started at #{@@host}:#{@@port}..."
      
      return t

    end


    def Peer.remote_subscribe(uid, pwd)
      msg = Peer.join(uid, pwd)
      cpa = []
      @@service_module.constants.each { |c|
        if @@service_module.const_get(c.intern).is_a?(Class)
          cpa << c
        end
      }
      msg['CPA'] = cpa
      return msg
    end
    
    
    def Peer.remote_unsubscribe(sid)
      return Peer.drop(sid)
    end
    

    def Peer.remote_new(cid, arg)
      obj = @@service_module.const_get(cid).new(*arg)
      oid = Peer.add(obj)
      return Remote_Object.new(Peer.peer, oid)
    end
    
    
    def Peer.remote_call(oid, mid, arg)
      robj = Peer.get(oid).send(mid, *arg)
      #roid = robj.id
      return robj #Remote_Object.new(Peer.peer, roid)
    end
    
    
    # Session Management
    
    def Peer.subscribe(peer, username='', password='')
      
      # request subscription from peer
      req = { 'REQ' => 'subscribe', 'UID' =>  username, 'PWD' => password }
      
      host, port = peer.split(':')
      port = port.to_i
      session = TCPSocket.new(host, port)
      
      yreq = req.to_yaml
      yreq_size = yreq.size
      session.write([yreq_size].pack("N") + yreq)

      yam_size = session.read(4).unpack("N")[0]
      yam = session.read(yam_size)
      msg = YAML.load(yam)

      sid = msg['SID']
      cpa = msg['CPA']

      #acpa = []
      #ObjectSpace.each_object(Class) { |c|
      #  acpa << c.name
      #}
      #dcpa = cpa - acpa
      cpa.each { |class_const|
        eval(%Q{
          class #{class_const}
          end
        }, $topbinding)
      }
      session.close
      return sid
      
    end
    
    
    def Peer.unsubscribe(peer, sid)
    
      # request subscription from peer
      req = { 'REQ' => 'unsubscribe', 'SID' =>  sid }
      
      host, port = peer.split(':')
      port = port.to_i
      session = TCPSocket.new(host, port)
      
      yreq = req.to_yaml
      yreq_size = yreq.size
      session.write([yreq_size].pack("N") + yreq)
      
      yam_size = session.read(4).unpack("N")[0]
      yam = session.read(yam_size)
      msg = YAML.load(yam)
    
      session.close
      return msg
    
    end
    
    
    def Peer.join(username, password)
      if Peer.validate(username, password)
        sid = "#{@@sessions.length}#{username}"
        @@sessions[sid] = true
        return { 'SID' => sid }
      else
        return { 'ERR' => 'invalid identity' }
      end
    end


    def Peer.drop(sid)
      if @@sessions.include?(sid)
        @@sessions.delete(sid)
        return { }
      else
        return { 'ERR' => 'not subscribed' }
      end
    end


    def Peer.validate(username, password)
      return true
    end


    def Peer.member(sid, password)
      return @@sessions.include?(sid)
    end


    # Object Pool Management
    
    def Peer.add(obj)
      oid = obj.object_id
      if not @@pool.has_key?(oid)
        @@pool[oid] = obj
      end
      return oid
    end

    def Peer.get(oid)
      return @@pool[oid]
    end

    def Peer.delete(oid)
      if @@pool.has_key?(oid)
        @@pool.delete(oid)
      end
    end

  end  # Peer

end  # ONI
