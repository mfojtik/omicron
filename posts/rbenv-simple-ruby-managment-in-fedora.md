title: rbenv - a better alternative for rvm in Fedora
updated: 03/Sep/2012 22:00
###

If you are Ruby developer, you may know that there is more than one Ruby
platform. Sometimes it is important to easy switch between them, without messing
up the operating system and installed gems.

So far, the most popular utility for managing multiple Ruby distributions is
[RVM](https://rvm.io/). However this tool goes far beyond to just switching Ruby
versions. It has bundled gem sets management, it patches Ruby to achieve better
integration and many other ugly things. For some, like me this system is just
'too much'. All I want is nice way to switch between 1.9 and 1.8 MRI and
sometime use jRuby to see how my code performs on this platform.

Hopefully I don't need to mess up my bash environment anymore. Recently I found
[rbenv](https://github.com/sstephenson/rbenv). A new very minimal replacement
for RVM. The rbenv does not override the user environment variables if you don't
want to and follow traditional UNIX approach of having things that do one thing
and do it well.

The 'rbenv' also use bundler (the most hated gem management ;-) to install
gems. Gems are installed as usual to user $HOME directory and no additional
magic like gemsets or special growing directories is included.

Installing rbenv on Fedora 17 is easy. There is no need to run obscured scripts
from internet using curl. No need for root privileges.You just need to clone
rbenv GIT repo:

<pre class='sh'>
cd $HOME
git clone git://github.com/sstephenson/rbenv.git .rbenv
</pre>

Now to have access to executables installed by gems, you need to alter your
$PATH:
<pre class='sh'>
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
</pre>
And finally you need to load 'rbenv' to enable bash autocompletion and plugins:
<pre class='sh'>
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
</pre>
Now you're ready to use rbenv. Do not forget to reload your bash session to
pickup new environment.

By default, rbenv does not include any fancy installer and it forces you to
install all Ruby versions by hand, using traditional configure && make.

If you like more user-friendly method, then you need install 'ruby-build' plugin:
<pre class='sh'>
mkdir -p ~/.rbenv/plugins
git clone git://github.com/sstephenson/ruby-build.git \
   -O ~/.rbenv/plugins/ruby-build
</pre>
Now, you can use more friendly <code>rbenv install VERSION</code> command. To get list
of all possible platforms, type 'rbenv install -l'.

If you're on Fedora 17 and you have problems building Ruby 1.8.7-p370 (dl.c)
you can fix it by using this command:
<pre class='sh'>
CONFIGURE_OPTS=--without-dl rbenv install 1.8.7-p370
</pre>
Switching between different Ruby versions is not so user-friendly as with RVM
(but you can install plugin to make it looks the same ;), but you satisfy comfort
by having clean environment and 100% original not patched Ruby.

There are many different ways how to switch between Ruby versions. For example
your can use 'rbenv local VERSION' command that will create .rbenv-version
file in the current folder. Then everytime you execute 'ruby' in this directory,
rbenv will use the version you saved into this file.

Another, temporary option is to prefix 'ruby' command with RBENV_VERSION
variable.

I use rbenv as a replacement for RVM couple weeks and I can say I'm quite
happy with it. It's simple, has many plugins (each, gems, etc) and I'm sure
I use the original MRI versions.

