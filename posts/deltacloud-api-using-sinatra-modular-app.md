title: Deltacloud API using modular Sinatra way
updated: 03/Apr/2012 22:50
###

When we started the [Deltacloud API](http://deltacloud.org) project three years
ago, we thought the best way how to do it would be to use the
[Sinatra](http://www.sinatrarb.org) framework. This Ruby framework provides a
simple DSL for writing *small-size* web applications. And since Deltacloud API
does not use any database or complicated messaging system it is perfect use-case
for **Sinatra application**.

However, after a while, we realized that using just plain Sinatra routes is not
perfectly DRY, since we
repeated too much code and actions. So we developed the **Rabbit**. This small DSL
allows us to build a robust REST API application with many collections and
operations with just little effort.

After a while, the Sinatra guys came with a [new
approach](http://www.sinatrarb.com/extensions.html) how to write applications.
Instead of using the *application way*, where you type routes directly to the
Ruby file, you can create classes, inherit from `Sinatra::Base` class and then
run these classes as [Rack](http://rack.rubyforge.org) containers.
This approach has many benefits. The biggest one is that every Sinatra class
could be mounted as a **Rack container** to other Rack compatible framework (like
Rails). In simple words, you can connect pieces of your web application like
puzzle. The second benefit is that your application doesn't run immediately
after it's launched by the Ruby interpreter. Instead you need to use some 'rack'
deployer, like `rackup` or `thin` to spawn the whole application.

We realized that using the 'old' way to write Sinatra apps could be somehow
limiting us in future and it could disallow us to use power of the Rack containers.
Also, we keep listening to community and community is demanding a **Ruby library**,
that will use our 'drivers' with a rock solid API, just like `fog` is doing.

So I spent several hours thinking about how to simply rewrite Deltacloud API in
the Sinatra modular manner. It looked to be an impossible task in begging but I
accepted that challenge.

The first puzzle which was needed was the Rabbit DSL. The web part of Deltacloud API
is written entirely in this framework, so changing it back to plain routes would
cause Rabbit to loose all the powerful features it has.

So I [extracted
Rabbit](http://mfojtik.im/creating-rest-based-api-with-sinatra-rabbit) out from
Deltacloud API and published it on
[Github](http://github.com/mfojtik/sinatra-rabbit). I rewrote it from scratch, but
I tried very hard to preserve all the features and syntax we are used to work
with. I think I was pretty successful in this and Rabbit is now feature complete
with ~90% of code coverage.

The next hard step was to deal with different features, we have in Deltacloud
API that are very tide to our drivers, like 'features', 'dynamic driver
switching' or 'capabilities'. Those bits were very important to us, so changing
them or removing them would break our promise of backward compatibility.

So currently, I have almost all
[collections](https://github.com/mfojtik/deltacloud-modular/tree/master/lib/deltacloud/collections)
ported to modular Deltacloud API, and almost all drivers work as well. Those
drivers which do not work now , require just small tweaks to start working
properly. You can see the progress in another [Github
repository](http://github.com/mfojtik/deltacloud-modular).

Of course, I have made big changes to our internal code structure. First, all
collections are implemented as independent `Sinatra::Base` classes and isolated
in application as 'modules'. The simple *collection* looks like this:

<pre class="sh_ruby">
module Deltacloud::Collections
  class Realms < Base

    collection :realms do

      operation :index do
        control { filter_all :realms }
      end

      operation :show do
        control { show :realm}
      end

    end
  end
end
</pre>

As you can see, the syntax is the same as in internal Deltacloud API Rabbit,
however there are some tweaks I made to make it more effective. The first tweak
you can see is that for the `:show` operation, there is no `param :id` defined.
I realized that some particular REST operations we have in Rabbit, always set
this parameter, so now Rabbit will **do it automatically**. The next thing is that I
removed `description` (well is still there). The truth is that we did not used it
too often and the description of collections and operations was just repeating
all the time. Now Rabbit is generating this automatically as well.

There are more tweaks I want to demonstrate on the other collection example:

<pre class="sh_ruby">
module Deltacloud::Collections
  class Instances < Base

    check_capability :for => lambda { |m| driver.respond_to? m }
    check_features :for => lambda do |c, f| 
      driver.class.has_feature?(c, f)
    end


    features do
      feature :user_name, :for => :instances do
        description "Allow to set user-defined name for the instance"
        operation :create do
          param :name, :string, :optional
        end
      end
      # ...
    end

    collection :instances do

      operation :index, :with_capability => :instances do
        param :id,            :string,  :optional
        param :state,         :string,  :optional
        control { filter_all(:instances) }
      end

      operation :show, :with_capability => :instance do
        control { show(:instance) }
      end

      operation :create, :with_capability => :create_instance do
        param :image_id,     :string, :required
        param :realm_id,     :string, :optional
        param :hwp_id,       :string, :optional
        control do
          @instance = driver.create_instance
          # ...
        end
      end

      action :reboot, :with_capability => :reboot_instance do
        description "Reboot a running instance."
        control { instance_action(:reboot) }
      end

      action :start, :with_capability => :start_instance do
        description "Start an instance."
        control { instance_action(:start) }
      end

      action :stop, :with_capability => :stop_instance do
        description "Stop a running instance."
        control { instance_action(:stop) }
      end

      operation :destroy, :with_capability => :destroy_instance do
        control { instance_action(:destroy) }
      end
    end
  end
end
</pre>

The first things you can see are the `check_capability` and the `check_features`
methods in the very beginning of the class. These 'triggers' will set a lambda
(Ruby stored procedure) and will call this lambda when processing the HTTP request.

The capability check will assure that method required for executing operation is
available in the driver. So in other words, when the driver does not have
`create_instance` method defined, the `:create` operation will return HTTP
status 417 (Precondition failed) to the client. The reason I used lambda function is
that the `driver` variable can change 'per-request' as the client switch the
Deltacloud API driver. So the evaluation whether the operation should be executed or
not is done for every request. The `:with_capability` option will tell Rabbit
what method should be checked on driver.

The next important things are **features**. In Deltacloud API we support many
cloud providers and for some of them you can use additional parameters in the HTTP
request to set or change features, that are available only for a particular
driver.

And since the Rabbit and Deltacloud API are now completely separated, there is
no longer connection from Rabbit to the drivers code. In fact, Rabbit can be used
now for any other Sinatra-based project. So I added another lambda, to check if the
driver that is currently set for the current HTTP request has defined the given feature.

If it has the feature defined, then we add a new parameter to the particular operation.
In simple words, if the *EC2 driver* has **user_data feature** enabled in the driver,
then additional `:user_data` parameter will be added to the `:create` operation.

The last, but important change is that I renamed those operation which always
acts as 'actions' to `action`. This operation will automatically get the `:id`
parameter and is defined as HTTP POST (this can be changed using `:http_method`).

I think the biggest pain is now resolved and there is now a way to go to implement
modular Deltacloud API. There is still a ton of work to be done, like importing
all the unit tests and cucumber tests we have in Deltacloud currently, or the automatic
documentation system.

The project could be now deployed or mounted as regular Rack container. I used
the `config.ru` file, which define how it should be started:

<pre class="sh_ruby">
  map '/api' do
    use Rack::Static, :urls => ["/stylesheets", "/javascripts"], 
                      :root => "public"
    run Rack::Cascade.new([Deltacloud::API])
  end
</pre>

The same approach can be used in Rails or Padrino framework, so in theory, you
can access Deltacloud API without your application, without running it as
separate daemon.
