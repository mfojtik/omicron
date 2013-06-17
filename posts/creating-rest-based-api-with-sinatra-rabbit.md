title: Creating REST API's using Sinatra and Rabbit
updated: 14/Mar/2012 23:00
###

When we started working on [Deltacloud API](http://deltacloud.org) rewrite to
[Sinatra](http://www.sinatrarb.com), we realized that creating routes for
every single Deltacloud collection can be pretty frustrating. Usually, when you
writing **REST** based application in Sinatra you end-up with typing the same
**CRUD**
operations for every collection of resources your application have.

This was a bit frustrating, since many operations are similar and basically
doing the same thing. For example the 'show' operation is usually defined like this:

<script src="https://gist.github.com/2039912.js?file=show.rb"></script>

Basically you type this code over and over for all <code>:show</code> operations.
The only thing you change is the 'item'.
Also if you want to have your API easy discoverable for clients, you also need
to define *OPTIONS* and *HEAD* routes to advertise supported operations or
parameters.

The powerful weapon that Ruby allows to programmers do, is easy
[DSL](http://www.artima.com/rubycs/articles/ruby_as_dsl.html) creation.  So we
decided to move over and replace the non-DRY, hard to read code with some
elegant DSL. We call it Rabbit and we basically use it to serve all collections
and operations. The only mistake we made in time when we started to write Rabbit
was that we use classic non-modular Sinatra style.

Since Rails and other frameworks support
[mounting](https://github.com/josh/rack-mount) of 'rack' applications, the
importance of having the 'modular' Sinatra applications is growing up.
And we need to somehow follow this movement too. 

As a first step I started working on moving Rabbit (our DSL) away from the
Deltacloud project to make it as upstream rubygem, that could be included into
any Sinatra application (both modular and non-modular). I created a
[repository](https://github.com/mfojtik/sinatra-rabbit) on
[Github](http://github.com) and today, version
[1.0](http://rubygems.org/gems/sinatra-rabbit/versions/1.0) was released.

Introduction to Rabbit
-----------

Let start with very simple, REST based, modular Sinatra app:

<script src="https://gist.github.com/2040049.js?file=rabbit_example1.rb"></script>

In begging, we need to require the <code>sinatra/rabbit</code> Sinatra
extension.  This extension is shipped as rubygem and can be installed using
<code>gem install sinatra-rabit</code>.  Requiring Rabbit isn't invasive and
will not extend the Sinatra::Base class with Rabbit methods automatically. To do
so, you would need to do <code>include Sinatra::Rabbit</code> inside your
Sinatra::Base class (MyApp in this case). This allows you to use the DSL
syntax sugar in MyApp class, but also keep the good old Sinatra routes and helpers
available.

The <code>collection</code> method is used to declare a new resources collection.
The one in example above represents 'images'. All collections and operations can have
description set using the <code>description</code> method. This description will be
used later for automatic documentation generation. This is not implemented yet.

The DSL define standard set of CRUD operations and will automatically add
corresponding HTTP method to each operation. For example the <code>:create</code>
operation will automatically be defined as <code>POST /images</code> and the
<code>:destroy</code> operation will get the HTTP DELETE method.

Operations can also use various POST/GET parameters. For example in the
<code>:create</code> operation the <code>:name</code> parameter is required.
But as you see, there is no validation in the <code>control</code> block. Trick
is that the parameter validation is done automatically. So whenever the 'create'
operation is called without the 'name' parameter, Rabbit automatically reply with
the 400 HTTP status code, including missing parameter in the HTTP body response
for the client.

The <code>control</code> block is used to determine what code will be executed
when client access the operation. You can use all Sinatra helpers, like template
helpers (haml, sass, ...) or flow helpers (halt, status, ...) freely inside this
block.

Advanced features
-------

With the power of DSL, you can play with the code more and make it more abstract
and mote easy for user to understand. Besides route generation and parameter
validation, Rabbit also support more advanced features which can be handy:

Conditional routes
-------

<script src="https://gist.github.com/2040178.js?file=cond_routes.rb"></script>

Using the <code>:if</code> option in the operation definition will make 'skip'
that operation if the condition given as value is evaluated as false.

Sub-collections
-----

<script src="https://gist.github.com/2040191.js?file=subcollections.rb"></script>

In some specific use-cases, you want to have sub-collection of resources. In
example above, we have collection <code>:buckets</code>. This collection
represents something like a directory, which can store files (blobs). You can
have multiple buckets and each bucket can have multiple blobs.

Client discovery
-----

Rabbit will automatically define couple routes around collections or operations.
These routes can help to your clients to discover API structure, like to get
list of operations defined for collection or list of parameters defined for
the operation.

For example requesting <code>OPTIONS /images</code> (OPTIONS is HTTP method)
will give you list of available operations in 'images' collection.  Also
requesting <code>OPTIONS /images/create</code> will give you list of
parameters that this operation supports.
