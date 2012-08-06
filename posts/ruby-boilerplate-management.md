title: Bootstraping Ruby application development with boilerplates
updated: 06/Aug/2012 12:30
###

You know it, you've got an idea but the process of getting all files in place is
boring and slows you down. In the end, you find yourself dealing with CSS and
DataMapper configuration rather than working on the 'real' application logic,
which I found very frustrating.

Boilerplater
---------------

Because I don't want to start all the time from the scratch, I created a small
Ruby utility to help me bootstrap my new application development.

*Boilerplater* is a [GIST](https://gist.github.com) based boiler plating managment
tool that helps me start working on various projects without passing the boring
initial setup.
How it works? It uses GIST to store the 'project template', specially annotated
text file that contains definition of project files.

Each file is separated by '## filename' followed by its content. Some files
might be downloaded from elsewhere (like CSS or Jquery). For that you can
instruct boilerplater to download files and store them into defined locations.

Example:

<script src="https://gist.github.com/3265768.js"> </script>

In this case, boilerplater will create Gemfile, app.rb, views and download
the twitter bootstrap CSS files to the 'public/css' folder. You can start
immediately hacking your app.

Boilerplater come with handy command-line tool called <code>bp</code>:

<code>$ bp</code>
<pre>
Usage: bp command [id|alias|action] [options]

Commands:

  bp list                         - List all boilerplates
  bp search [name]                - Search for boilerplate
  bp show   [id|alias]            - Show boilerplate details
  bp use    [id|alias]            - Apply boilerplate
  bp alias  create [id]    [name] - Create alias for boilerplate
  bp alias  delete [name]         - Delete alias
  bp alias  list                  - List all aliases

Options:
  --prefix, -p <s>:   Prefix for boilerplate files (default: .)
        --help, -h:   Show this message
</pre>

You can use whatever GIST you want as a boilerplate, just add the GIST
ID into the <code>bp use ID</code> command. Since the GIST id is not the thing
I want to keep in mind all the time, I added possiblity to create simple
aliases that are stored locally on your computer. For example:

<code>$ bp alias create 3265768 sinatra</code>
<code>$ bp use sinatra</code>

And because it would be nice to collect all available boilerplates somewhere,
I created a special [GIST](https://gist.github.com/3266785) that collect them
in 'GIST_ID;description' format. This will allow to search and list available
boilerplates. If you have a boiler plate you want to share, simply open an pull
request on the GIST above.

To learn more, read the code, navigate to [boilerplate GIT repo](https://github.com/mifo/boilerplater).
