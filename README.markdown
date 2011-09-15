# Mongui

Mongui is a graphical interface for viewing and (eventually) editing data in a Mongo DB.

Mongui has a client/server architecture that relies on severaly open-source frameworks that are widely used.


## Server

The server is built off of the Sinatrarb framework: [http://sinatrarb.com/](http://www.sinatrarb.com/)


## Requirements

The following ruby gems are required to run the server:

Required Gems:

* bson (1.0)
* json (1.4.3, 1.2.0)
* mongo (1.0, 0.19.1)
* rack (1.1.0)
* sinatra (1.0, 0.9.4)

Optional gems:

* bson_ext (1.0)
* mongo_ext (0.19.1)
* thin (1.2.7)
* yajl-ruby (0.7.5)



## Driver File:
By default, the server connects to localhost.  To override this add a file named  'mongo_hosts.dat' in the same directory as mongui.rb.

The file should contain the address of all your Mongo DB servers.  One per line.

* localhost
* localhost:27017
* username:password@localhost
* username:password@localhost:27017


## Running the server:
ruby mongui.rb  - this will run the server on port 4567

ruby mongui.rb -p <PORT>  - run Mongui on a different port. See the Sinatra link above for more server options.


## Client

The [ExtJS framework](http://www.extjs.com/) is required to run the client, <strike>but is not</strike> and it's included with the repo _(v3.2.1)_.

### Running the client:

Point your browser to *http://localhost:4567/mongui.html*  after you have the server running. 

If you used the '-p' option when running the server you will need to change the port accordingly.


### Usage:

If all is well so far you will see a three-paned webpage appear. 

Left-pane, a drill down of Host/DB/Collection.   Drill down and double click a selection.

Double-clicking takes you to the the 'Collection Data' tab which shows you a few documents from your collection.

To run a query, enter it in the upper pane and press 'Run Query'.  This will change your view to the 'Results' tab and show you your data.

**Hot-Keys:**

* CTRL R - Run Query
* CTRL T - New Query Tab


You did it!

## Help

If you have any idea, please send me an issue or fork the project, do it yourself and send me a pull request.

*Feel free to change the world =)*
