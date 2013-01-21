require 'bundler'

Bundler.setup :default
Bundler.require :default

require File.join(File.dirname(__FILE__), 'app.rb')

run Mifo::Site
