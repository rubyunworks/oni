# ONI - Object Network Interface
# Copyright (c) 2002 Thomas Sawyer, LGPL

class Class

  def oni_new(peer, *args)
    roargs = []
    args.each { |obj|
      if obj.is_a?(Remote_Object)
        roargs << obj
      else
        oid = ONI::Peer.add(obj)
        roargs << Remote_Object.new(Peer.peer, oid)
      end
    }
    req = { 'REQ' => 'new', 'CID' =>  self.name, 'ARG' => roargs }

    host, port = peer.split(':')
    port = port.to_i
    session = TCPSocket.new(host, port)

    yreq = req.to_yaml
    yreq_size = yreq.size
    session.write([yreq_size].pack("N") + yreq)

    yam_size = session.read(4).unpack("N")[0]
    yam = session.read(yam_size)
    ro = YAML.load(yam)
          
    session.close
    return ro
  end

end
