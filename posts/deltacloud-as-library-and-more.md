title: Deltacloud is now modular and offers the drivers API
updated: 22/May/2012 14:50
###

The [Deltacloud API](http://deltacloud.org) revamp is now done and pushed to our
[master GIT repo](https://git-wip-us.apache.org/repos/asf/deltacloud.git).  The
revamp itself does not affect the backward compatibility nor introduces any API
schema changes. The main goal of this work is to make Deltacloud API a [modular
Sinatra](http://www.sinatrarb.com/intro#Modular%20vs.%20Classic%20Style)
application, thus pluggable to any other Rack-based web application (Rails,
Padrino, Sinatra, etc..). As a side effect, since we do not use the Sinatra
methods in a global namespace, this revamp also introduces the possibility to
use Deltacloud API as a Ruby library. It means that in case you don't want to use
the REST server or for some reason (networking, security, etc...) you can't, you
can now just <code>require 'deltacloud/api'</code> and profit from the
drivers API. Please note that the library code is now **very experimental** and we
don't promise that it will work as you expect or it will not change in the near
future.

So how does the Sinatra::Base code work? After you install the <em>'deltacloud-core'</em>
gem, you should be able to just <code>require 'deltacloud_rack'</code> and then mount the DC
API container in this way:

<pre class="sh_ruby">
require 'deltacloud_rack'

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '0.5.0'
  server.klass 'Deltacloud::API'
end

run Rack::Builder.new {
  use Rack::MatrixParams
  use Rack::DriverSelect

  run Rack::URLMap.new(
    "/" => MyApplication.new,
    "/api" => Deltacloud[:klass],
  )
}
</pre>

There are several use-cases when the Sinatra::Base approach could be useful.
In case you need for some reason to add your own collections or just introduce
some 'stateful' operations, it should be much more easy now than with
the Sinatra::Application we were using before.

The other, very nifty feature is that you can now use Deltacloud drivers API
in your Ruby applications without even starting a REST server. This could be
handy if you're stuck with gems like 'fog', or your application requires a very
consistent API with the same abstraction for all cloud providers.

There is a small code example how you can use the library code:

<pre class="sh_ruby">
require 'deltacloud/api'

Deltacloud.new(:ec2, :user => API_KEY, :password => API_SECRET) do |c|
  c.create_instance('ami-12345')
end
#
# or
#
Deltacloud.new(:mock) do |driver|
  puts driver.hardware_profiles
end

</pre>

The drivers API is described
[here](http://deltacloud.apache.org/developers.html#h2_4), but the new, more
detailed documentation should appear soon. Meanwhile, you can use the
[YARD](http://omicron.mifo.sk/deltacloud-core/doc) documentation I generated.
