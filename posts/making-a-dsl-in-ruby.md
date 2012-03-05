title: Making a DSL in Ruby
updated: 25/Dec/2011 12:30
###

The main goal of writing such thing as a DSL is ussualy helping yourself to not
repeat the same code over and over (keeping code DRY). Tradeoff for this
approach is ussualy a piece of unreadable and complex code with simple purpose:
To handle this DSL and translate it to Ruby language. Lets take a quick example:

rule :apache do
  enable 80
  enable 8080
  enable 443
  name 'example.com'
  directory '/var/www/example.com'
  update 120
end

This DSL is self describing. It creates a configuration rules for Apache.
However this example also introduce some basic mistakes which people ussualy
do when designing DSL. First of all, the original idea of writing such thing
is to keep code DRY. Now look again on example above. The word 'enable' is used
there three times, which definitely isn't DRY. The proper syntax should be:

rule :apache do
  enable 80, 8080, 443
end

Now, the ugly next thing on the DSL sample above is that it's not descriptive
enough. If you're spending the time on writing code that will handle example
above, lets take few extra minutes and think about the right methods names.
For example the property 'name' says nothing about its suppose. Perhaps it's
name of the rule or the domain name. This automatically force further
implementors to look inside documentation, which is 'wrong'. Lets refactor this
example once again:

rule :apache do
  enable 80, 8080, 443
  domain 'example.com'
  root_path '/var/www/example.com'
  update_interval 120
end

The last nasty nit of our DSL example is the fact that reader (you ;-) have no
clue about what the value of 'update_interval' is set to. Is the '120' value
specified in minutes? Or perhaps in seconds? This sort of questions are ussualy
wrong and confuse people. How about using something like this:

rule :apache do
  update_every 2.minutes
end

Since every class in Ruby is open, it's easy enough to add methods like
'.minutes' or '.seconds' to Integer class.

Now, when we're happy with the architecture of our DSL, lets implement it in
Ruby. As you may guess, when there is word 'do' in Ruby it ussualy means a
'block'. You should get familiar with this Ruby feature ASAP, otherwise the code
below will look cryptic for you :-)

First we're going to implement the 'Rule' class. It's a good practise to use
class name same as the root of DSL.

class Rule 
  attr_accestor :name, :ports, :domain, :root_path, :update_interval

  def initialize(name, &block)
    @name = name
    instance_eval(&block) if block_given?
  end

  def enable(*ports)
    @ports = ports.map
  end

  def domain(name)
    @name = name
  end

  def root_path(name)
    @root_path = name
  end

  def update_interval(interval)
    @update_interval = interval
  end

end

Now, if you look on the code above, the first thing that will hurt your eyes is
that methods for setting variables is not really DRY. We're repeating the same
pattern in setting instance variables. Now, lets refactor this code a little
bit:

class Rule 
  attr_accestor :name, :ports
  (@@config_attrs = [ :domain, :root_path, update_interval ]).each do |a|
    attr_accessor a
  end
  

  def initialize(name, &block)
    @name = name
    instance_eval(&block) if block_given?
  end

  def enable(*ports)
    @ports = ports.map
  end

  def method_missing(name, *args)
    if name.member_of(@@config_attrs)
      send(name+"=", args.first)
    end
  end

end
