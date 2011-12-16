title: How to create a new Deltacloud API driver
updated: 10/Aug/2011 12:30
###

Even if we try hard in [Deltacloud project](http://deltacloud.org) to support as
many different cloud providers as we can, we just can't cover every cloud. Also,
it might come that you're building your own cloud based on some
virtualization like [libvirt](http://libvirt.org) or Xen and you have your
custom tools to manage it but you want to offer a **REST API** for your service
to make your customers happy. Then this small guide might be handy for you.

Collecting collections
--------------

Basically Deltacloud API provide access to cloud services through different
collections. In REST terminology a collection is set of resources. So far
Deltacloud API offers this basic collections for every driver:

* Hardware Profiles (/api/hardware_profiles)
* Realms (/api/realms)
* Images (/api/images)
* Instances (/api/instances)

Hardware profiles
-----------

To explain them briefly, the Hardware Profile determines how your virtual
machine will be sized. Practically, you can specify how much CPUs, memory and
storage your machine will consume. Ussualy, these hardware profiles are defined
statically in a driver using our DSL like:

<script src="https://gist.github.com/1485993.js"> </script>

As you can see, this DSL allows you to use ranges or enumerative properties.
This would be handy if the client want to have a bit of freedom on what size he
currently wants.

Realms
-----------

Realm basically represents a datacenter or a location of where your machine will
be deployed. This doesn't mean only geographical location but it can also
represent a place in your data center where it will be placed. For better
understanding, you can imagine that you have two Realms. First for 'development'
where your development machines live and one for 'production' where all your
production virtual machines reside. If you have a tool to list all your realms,
you can use it in a driver method, otherwise they can be defined
statically like:

<script src="https://gist.github.com/1485995.js"> </script>

The last method is used across the drivers to filter final results. It's not the
perfect way of how to 'filter' whole collection. Some 'cloud' providers offer a
method to get just one single realm which is in some cases much faster than
filtering the whole set.

Images
-----------

Image stands for a virtual machine template. Long story short, it represents a
recipe of how a new machine will be built. In EC2 or Rackspace it stands for a
pre-installed operating system image you can convert to your instance.  In
VSphere driver it represents a virtual machine, marked as a template you can
clone to a regular virtual machine. In your cloud, it can represent a prepared
QCOW image you just copy over and launch via libvirt or other virtualization
tools. In a Deltacloud driver, Image is defined like: 

<script src="https://gist.github.com/1485999.js"> </script>

A state represents the current state of an image. It might indicate to user
whether image is available or not, since sometimes the image is being built or
updated.

Instance states
--------

Almost done, but one part is still missing there. Instance represents a realised
virtual machine. So take all previous resources and you can create a new
instance.

Actually the Instance resource in Deltacloud API is the only object which has a
real state. According to the state of the Instance, client is able to execute
particular operations on it, like start, stop or destroy.

It's up to you how you describe a behavior of your cloud. For inspiration you
can take a look on the EC2 state-machine. It's defined using our DSL inside
driver:

<script src="https://gist.github.com/1486003.js"> </script>

It would take a while to actually understand this but it's very important and it
basically describes a behaviour of your cloud implementation.

Instances
------------

Now is the time to implement the Instance collection. In Deltacloud, it's
implemented like:

<script src="https://gist.github.com/1486005.js"> </script>

As you can see, an Instance resource references to an Image, Realm and
HardwareProfile. The Hardware Profile is a bit tricky, since it became an
Instance Profile once it's used with Instance.  The public_addresses property
tells user an IP address he can use for connecting to the instance. The username
and password properties are optional and you can also use the 'key' property if
you want to use public_key authetication (for SSH).  Property which is
responsible to track the state of the Instance is 'state'. Instance should have
state defined in your state machine (see top). To advertise the currently
available actions to the user you can use our 'instanceactionsfor' helper.

Instance actions
------------

Since the Instance object is 'creatable', you must define the 'create_instance'
method in your driver in order to allow Instance creation. This method looks
like:

<script src="https://gist.github.com/1486006.js"> </script>

This method should return an Instance resource after successful create
operation. To manage your instances you need to add method for all actions
defined in your state machine like:

<script src="https://gist.github.com/1486007.js"> </script>

After this, you're done and you have a fully functional Deltacloud driver.
Besides this brief tutorial, you should take a look on the available drivers
source code and also read the our official documentation available on Deltacloud
web site.
