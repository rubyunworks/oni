# ONI - Object Network Interface
# Copyright (c) 2002 Thomas Sawyer, LGPL

class Module
  public :undef_method
end

module ONI

  class Remote_Object
    
    attr_reader :peer, :oid
    
    def initialize(peer, oid)
      @peer = peer
      @oid = oid
      methods.each { |mid|
        if not [ 'inspect', 'instance_eval', 'instance_variables',
                 '__id__', 'object_id', 'id', 'new', 'methods', 'method_missing',
                 'oid', 'peer', 'to_yaml', 'to_yaml_properties', 'to_yaml_type',
                 'undef_method', 'class', '__send__', 'send'].include?(mid)
          #puts mid
          self.class.undef_method(mid.intern)
        end
      }
    end

    def method_missing(mid, *args)
      roargs = []
      args.each { |obj|
        if obj.is_a?(Remote_Object)
          roargs << obj
        else
          oid = ONI::Peer.add(obj)
          roargs << Remote_Object.new(Peer.peer, oid)
        end
      }
      
      req = { 'REQ' => 'call', 'OID' => @oid, 'MID' => mid, 'ARG' => roargs }
      
      # connect
      host, port = @peer.split(':')
      port = port.to_i
      session = TCPSocket.new(host, port)
      
      # write
      yreq = req.to_yaml
      yreq_size = yreq.size
      session.write([yreq_size].pack("N") + yreq)
      
      # read
      yam_size = session.read(4).unpack("N")[0]
      yam = session.read(yam_size)
      ro = YAML.load(yam)
    
      session.close
      return ro
    end
  
  end

end

