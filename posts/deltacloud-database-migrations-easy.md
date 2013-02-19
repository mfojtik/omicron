title: Sequel database migrations
updated: 19/Feb/2013 11:15
###

As we added the [database support to Deltacloud
CIMI](http://mifo.sk/how-we-start-using-database-in-deltacloud) using [Sequel
ORM](http://sequel.rubyforge.org/), the one problem we were thinking about were database migrations.
What if someone started using Deltacloud CIMI and meanwhile we made some changes
to the database schema?  For example, what if we added, renamed or deleted a new column in table?
In that case once we have pushed a new release out, this user would face to numerous
errors coming out from the Deltacloud server.

We don't want to force our users to erase their database every time we do a release.
Solution for that are *database migrations*. If you are familiar with
[Rails](http://guides.rubyonrails.org/migrations.html), you probably know how
migrations works. You basically have couple files that contains recipes how
the database should be created, what columns should be added, etc...
These files follow the chronological order, so you don't need to erase your DB
every time you change something.

Well, we are not using Rails, but Sequel. To write a new migration for Sequel,
you need to do the following:

**1. Create a new file inside server/db/migrations/* directory:**

This is the folder where we store DB migrations.

**2. The file should start with a number in chronological order:**

* `1_add_realm_to_machine_template.rb`
* `2_add_something_to_some_entity.rb`
* `3_your_file_here.rb`

**3. The content of file should be following:**

    # 3_your_file_here.rb:
    #

    Sequel.migration do

      up do
        add_column :entities, :realm, String
      end

      down do
        drop_column :entities, :realm
      end

    end

The *up* section basically says what should happen when this migration is
executed. In this example, we are adding a new column named 'realm' into the
'entities' table.

The *down* section describes what should happen when someone decides to
rollback your migration.

After you do this, you need to run the following command:

    $ ./bin/deltacloud-db-upgrade

(or just `$ deltacloud-db-upgrade` if you are gem user.)

If this command prints nothing, everything is fine and your DB is running
the latest schema.

So to wrap this up: instead of touching the `lib/db.rb` file in Deltacloud, when
you want to add some new column to the database, you **should** write a migration
script and then execute it.
