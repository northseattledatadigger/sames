#!/usr/bin/ruby

HereDs          = ENV['PWD']
HomeDs          = ENV['HOME']
SAMESHOME       = File.expand_path("..", __dir__)

RubyLibFs       = "#{SAMESHOME}/slib/SamesTopLib.rb"

if File.exist?(RubyLibFs) then
    require RubyLibFs
else
    m = "Sole argument must be valid filename of Ruby library."
    raise ArgumentError, m
end
