title: Howto deploy Deltacloud API in Red Hat OpenShift Paas
updated: 16/Dec/2011 12:00
###

As you may already know, [Red Hat](http://www.redhat.com) announced it's
own opensource PaaS called [OpenShift](#) this year.
As many other PaaS services, like [Heroku](#) you can deploy your Rack
applications easely using [GIT](#) without configuring anything.
Since the [Deltacloud API](#) project I'm working on is a [Sinatra](#)
application, thus Rack compatible, it would be great to offer our potential
users a way how to quickly deploy *Deltacloud API* inside *OpenShift*.
There are several benefits of doing that, like you don't need to mess
your system with installing Ruby libraries (which could be pretty painfull
process, especially in operating systems like Windows).
The other benefit is that you don't need to waste resources in your system
to run *Deltacloud API* (which is why this service is shamely called 'cloud').

Step 1. - Create OpenShift account
---------------------

In order to get *Deltacloud API* running in *OpenShift*, you of surely need an
[OpenShift account](https://openshift.redhat.com/app/user/new/express).
After you create one (it's free!), then be sure you provide your SSH public
key in Control Panel. This will make the authentication easier and you will
not be asked for a password everytime.

Step 2. - Install OpenShift tooling
---------------------

OpenShift use set of tools written in Ruby that make UI experience much better
than messing up with pure GIT. Since they are Ruby gems, you can easely install
them using <code>gem install rhc</code>. I'm sure they are also available as
RPM package, but since I'm OSX user, using gem was my preffered choice ;-)

Step 3. - Creating a new OpenShift application
---------------------

If you have tooling installed, you should get familiar with <code>rhc-create-app</code>
command (this command is part of 'rhc' gem you installed in previous step).
This command is used to create a new empty application inside OpenShift. There
are several types of frameworks OpenShift currently support. The one,
interesting for us is 'rack-1.1'. This platform is common in Ruby world as
unified interface for running web applications. Now the magic command is:

<pre>rhc-create-app -l mfojtik@redhat.com -a example1 -t rack-1.1</pre>

Where mfojtik@redhat.com is my OpenShift username and 'example1' is the name
of application I'm going to create.
After you created a new application 'rhc' command should tell you the URL for
this application and remote GIT repository, you will use for deploying your app.
The URL should looks like:

<pre>http://example1-mfojtik.rhcloud.com/</pre>

Step 4. - Deploying Deltacloud API
---------

The second information that 'rhc' will tells you is remote GIT repository.
It should looks like:

<pre>ssh://85a2e2af280e4314802@example1-mfojtik.rhcloud.com/~/git/example1.git/</pre>

The 'rhc' command will automatically *clone* this GIT repository into current
directory. Repository name should be the same as your application name
('example1' in this case).

Now you need to clone the Deltacloud API GIT repository:

<pre>git clone git://git.apache.org/deltacloud.git</pre>

Deltacloud API sources should be now present in 'deltacloud' directory.
Now we need to copy files, required to launch Deltacloud API to our
OpenShift application directory (`example1`):

<pre>cp -rv deltacloud/server/* example1/</pre>

It's seems like we're already done and ready for `git push` that will start this
application. But there is some additional fidling needed to get it running.
The first this is that in Deltacloud API we're using Ruby 'gemspec' to hold our
dependencies. This is somehow not acceptable for OpenShift, thus we need to
provide 'standard' Gemfile with list of dependencies that will be installed.
The 'Gemfile' file inside `example1` directory should looks like:

<script src="https://gist.github.com/1485921.js"> </script>

<span class="label notice">NOTE:</span> **The Rack version need to be set to
'1.1', otherwise the app will not be started.**

The next thing we need to alter is `config.ru` file. In Openshift this file
**must** contain `Bundler.require` method that will install all required Ruby
dependencies.
The modified `config.ru` should looks like:

<script src="https://gist.github.com/1485933.js"> </script>

Check the commented `ENV['API_DRIVER']` section. By default Deltacloud API is
being started with the 'mock' driver pre-enabled. To speak with [Amazon EC2](#)
or other cloud provider by default you can alter this environment variable in
config.ru file.
Note that you can still use all Deltacloud API driver, using 'matrix' parameters
in URL:

<pre>/api;driver=rackspace/instances</pre>

OK. Now we're ready for deploying Deltacloud API to OpenShift. First you should
lock all gem dependencies using `bundle` command inside `example1` directory.
Then you should add all files into GIT using:

<pre>git add -A && git commit -m "Initial import"</pre>

Then run `git push` and your instance of Deltacloud API should be available
on your application URL in a minute!
