# ONI - Object Network Interface
# Copyright (c) 2002 Thomas Sawyer, LGPL

require 'yaml'
require 'webrick'

require 'oni/class'
require 'oni/peer'
require 'oni/remote'

# TODO: Add VERSION constant.

#module ONI
#  require 'yaml'
#
#  metadata = YAML::load(File.open(File.dirname(__FILE__) + '.spec'))
#
#  metadata.each do |k,v|
#    const_set(k.upcase, v)
#  end
#end

