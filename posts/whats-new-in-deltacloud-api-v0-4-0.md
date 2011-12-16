title: Whats new in Deltacloud API v0.4.0
updated: 16/Sep/2011 12:30
###

Yesterday we proudly announced the official release of Deltacloud API version 0.4.0. I would like to share with us the new features which are included in this release. I took several month to bump the release version so the list of new things is pretty log.

New command-line options
---------------

The deamonized server is started on the background and it automatically logs to the system log. This option will be used widely in init scripts on Linux OS. To try it out just add --daemon option to deltacloudd.
Deltacloud supports variety of cloud providers via drivers. However it was pretty hard to get list of all supported drivers in your installation. Now we introduce the --drivers option which will show you all installed and ready to use drivers.
SSL support. This is not directly the Deltacloud API feature but the 'thin' feature which is the Ruby web server we're using to deploy Sinatra. Support for the SSL was imported to latest thin and Deltacloud API just exposes this feature to user via --ssl and --ssl-key command line options.
The new --config file option gives you ability to store backend cloud configuration in YAML file. You can store provider, username and password here so Deltacloud API will set those properties as default for the current instance.

New UI
---------------

We decided to put more effort into user experience and starting with this release, you can enjoy fabulous UI also on mobile devices. We chose jquery.mobile framework because we'd already been using JQuery and this framework is currently the most fastest growing mobile application web framework around. This UI change required a lot of work in our HAML view and caused various incompatibilities in old browsers.
All this should be fixed now. As a side project, I created a small DSL called rbmobile which helps programmers with JQuery UI HTML generation in HAML.

New packaging schema
---------------
Another huge change to Deltacloud API project. Currently, when you use Linux and RPM based distributions, you can install Deltacloud using the yum install deltacloud-core which pulls in all drivers with all their dependencies. But sometimes this is not what you really want.
Splitting the driver configuration enables us to create a set of subpackages for Fedora for each driver we support. Each subpackage tracks it own dependencies. For example, if you want to use Deltacloud with EC2, you can now install deltacloud (Deltacloud?) in Fedora using: yum install deltacloud-core-ec2. To install all drivers you can use yum install deltacloud-core-all.

Support for VSphere, RHEV-M 3.0 and Condor Cloud
---------------

This is probably the biggest feature of new Deltacloud API. We have full support for the VMWare Vsphere provider which includes basic collections as images or instances but also semi-advanced features like the user-data injection via virtual CD-ROM driver.
Secondly we improved our support for RHEV-M provider and fix all incompatibilities with upcoming RHEV-M 3.0 release (which is now beta1).
Was thinking about running your private cloud using libvirt with Deltacloud. I got numerous questions about this feature and now, the Condor driver is the answer. However, setup of this thing is not very easy but there should be a quick howto very soon. Meanwhile there is our devel howto available.
