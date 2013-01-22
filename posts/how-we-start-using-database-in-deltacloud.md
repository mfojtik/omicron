title: How we start using Sequel in Deltacloud
updated: 22/Jan/2013 11:15
###

Since I started working on [Deltacloud API](http://deltacloud.org), we always used to say that Deltacloud
is stateless and you don't need to have any persistence store. Well, that is no longer
true and we added the database as a dependency. But don't panic, Deltacloud
is still stateless and the database is here only to help our [CIMI implementation](http://deltacloud.apache.org/cimi-rest.html)
be even more awesome.

The story begun when we came across the problem of how to map some **CIMI entities**
and some properties to the backend providers. As you might now, not all cloud
providers do support setting a 'name' for the virtual machine neither they
support setting a `description` or `properties`. However, these attributes are
required in CIMI and if you create a new Machine with the description and the name and
as a result, you get a Machine without the`name` you choose, then you are kind of breaking
the CIMI standard.

Let me show you an example of __MachineCreate__:

    <MachineCreate>
      <name>myAwesomeMachine</name>
      <description>Description of my new awesome Machine</description>
      <machineTemplate>
        <machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-small"/>
        <machineImage href="http://localhost:3001/cimi/machine_images/img1"/>
      </machineTemplate>
      <property key="foo">bar</property>
    </MachineCreate>

This is kind of minimal `MachineCreate` XML. The `name` and the `description`
elements are required as the `machineTemplate`. The `property` element is optional,
however if you use this, the resulting Machine must advertise them.

However, if you use this specification to create a new __Machine__ in Amazon EC2, you will
get something like:

    <Machine>
      <name>i-123456</name>
      <description></description>
      <!-- other elements... -->
    </Machine>

There is no workaround how to store the value of the `name` property and other
properties in EC2 (except tags, but that is not cool :) ). Other providers behave
similarily or allow you to set the `name` but not the `property`, etc..

The only reasonable solution for this problem was to use some sort of
persistence layer on Deltacloud level that will store these attributes or
eventually full entities.

After we tried to use [DataMapper](http://datamapper.org/) (and succeeded) and after we discovered this
beautiful Ruby gem is not RPM packaged we ended up using the [Sequel](http://sequel.rubyforge.org/) ORM.

Sequel is a minimal [ORM](http://en.wikipedia.org/wiki/Object-relational_mapping) that does not have any external dependencies (AFAIK it
has no dependencies at all ;) ). It has a very powerful syntax that allows you to
chain SQL queries, use transactions, etc. And, it is packaged.

The first thing we did was creating a `db.rb` file that creates the schema
and handle connection to the database. There are just two interesting methods:

    def self.database(opts={})
      opts[:logger] = ::Logger.new($stdout) if ENV['API_VERBOSE']
      @db ||=  Sequel.connect(DATABASE_LOCATION, opts)
    end

The `DATABASE_LOCATION` constant is customizable using the `DATABASE_LOCATION`
environment variable. You are free to use whatever database you like. By default
we use SQLite3, but if you plan to use CIMI in production or you plan to share
the database with more than one instance of Deltacloud, you can use MySQL or PG.

The second interesting method is:


    def self.initialize_database
      db = database
      db.create_table?(:providers) {
        primary_key :id
        column :driver, :string, { :null => false }
        column :url, :string
        index [ :url, :driver ] if !db.table_exists?(:providers)
      }
      # ...
    end

This method handles the initial schema creation and migrations. Yes, sadly, Sequel
does not support cool automigrations, unlike DataMapper, but it is something you
can live with. On other hand, the creation schema DSL is very powerful and
allows you to do crazy things with database (creating indexes, etc).

If you wonder what the question mark after  `create_table` means, it makes sure
that the table is not created if it already exists. Using that, we don't need to
have separate migrations. When you start Deltacloud, we just make sure schema
exists and if not, we create it.

The database schema is very simple. We have the `Provider` entity and then the entity
called `Entity`. `Provider` contains informations about the current driver and
provider so we don't mess entities created using different drivers or providers.

The second table `entities` is more awesome. We use 'flat' table model, so we
don't have a table for every entity. We rather have just one wide table that
stores all of them. This will save us SQL queries and also make DB schema more
simple (and faster in result).

To manipulate with data, you will need to create [`Sequel::Model`](http://sequel.rubyforge.org/rdoc/classes/Sequel/Model.html) classes that
map to database tables. They are located in `server/lib/cimi/db` folder.

Besides the [ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html) or DataMapper models, the Sequel models are extremely
simple and easy to read. There is no need to define obscure validations not to
have million of scope declarations and methods. The `Entity` model looks like
this:

    class Entity < Sequel::Model

      many_to_one :provider

      plugin :single_table_inheritance, :model
      plugin :timestamps, :create => :created_at

    end

Yes. That is all. Just five Ruby lines and everything is done. By default, Sequel
is very minimal and does not handle the magic like the `created_at` columns. If
you want to have this, you just enable it by the `plugin` method.

As I mentioned before, we use single table for all entities. But we want to have
more models that are mapped to this table. Like the `MachineTemplate` model.
For that there is the 'single_table_inheritance' [plugin](http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/SingleTableInheritance.html). With this plugin, you can
create children models that will share the parent table schema. The children
model then looks like this:

    class MachineTemplate < Entity
      validates_presence_of :machine_config
      validates_presence_of :machine_image
    end

The `MachineTemplate` items will be stored in the `entities` table, with the
`model` column set to *MachineTemplate*.

Lets move forward to how we store and load the data stored in the persistence layer.
For that we created the 'database_helper.rb' file. It includes helper methods
that provide easy access to entities stored in database. In other words, we
don't need to call Sequel methods everywhere and once we discover a new way how
to optimize the SQL query, we do it on one place instead of editing n-files.

First method is `current_db`:

    def current_db
      Deltacloud::Database::Provider.find_or_create(:driver => driver_symbol.to_s, :url => current_provider)
    end

This method will always return the 'right' provider based on the currently used
Deltacloud driver and provider. (In Deltacloud you can [change driver](http://deltacloud.apache.org/drivers.html) and
provider per-request using HTTP headers).

Now when you got the current `Provider`, you can ask it for the entity:

    def get_entity(model)
      current_db.entities_dataset.first(
        :be_kind => model.to_entity,
        :be_id => model.id
      )
    end

The `model` attribute is an instance of the Deltacloud API model (like Instance or Image).
The 'extra' attributes are always mapped to the Deltacloud API model. So as I
mentioned above, the `name` or `description` of CIMI Machine is mapped to the
Deltacloud `Instance` model. And because we are not able to store these
attributes in backend cloud, we store them in the database.

The to load the attributes for this entity, you can use this method:

    def load_attributes_for(model)
      entity = get_entity(model)
      entity.nil? ? {} : entity.to_hash
    end

This method will return `Hash` with all 'extra' attributes that we store for the
given entity.

We just started adding support for this to all CIMI entities we currently
support. We also have some CIMI entities that are completely stored into the
database (like MachineTemplate) and we kind of play the 'provider' role in
CIMI terminology.

