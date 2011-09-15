require 'rubygems'
require 'mongo'
require 'sinatra'
require 'time'
require 'yajl/json_gem'

HOST_DATA_FILE = 'mongo_hosts.dat'
DEFAULT_HOST   = 'localhost'
DEFAULT_PORT   = "27017"

def get_hosts
    if File.exists? HOST_DATA_FILE
      t = {}
      File.open(HOST_DATA_FILE,'r').readlines.collect do |host|
        info = {
          :username     => nil,
          :password     => nil,
          :host         => nil,
          :port         => nil,
          :collections  => []
        }
        h = host.strip
        datas = h.split(/@/)
        if datas.length > 1
          info[:username], info[:password]  = datas[0].match(/:/).nil? ?
                                                [datas[0], nil] :
                                                datas[0].split(":")
          info[:host], info[:port]          = datas[1].match(/:/).nil? ?
                                                [datas[1], DEFAULT_PORT] :
                                                datas[1].split(":")
        else
          info[:host], info[:port]          = datas[0].match(/:/).nil? ?
                                                [datas[0], DEFAULT_PORT] :
                                                datas[0].split(":")
        end

        unless h.match(/\//).nil?
          info[:collections] = h.split(/\//)[1].split(/,/)
          info[:port] = info[:port].split(/\//)[0]
        end

        t["#{info[:host]}:#{info[:port]}"] = info
      end
      t
    else
        return {
          "#{DEFAULT_HOST}:#{DEFAULT_PORT}" => {
            :username => nil,
            :password => nil,
            :host     => DEFAULT_HOST,
            :port     => DEFAULT_PORT
          }
        }
    end
end

HOSTS = get_hosts

get '/' do
  redirect 'mongui.html'
end

post '/show_dbs' do
    counter = 1
    data = []

    HOSTS.each do |name, host|
        begin
          m = Mongo::Connection.new( host[:host],
                                     host[:port].to_i,
                                     :slave_ok => true)

          host_node = {}
          host_node[:id] = counter
          counter += 1
          host_node[:text] = name
          host_node[:icon] = 'images/blue.gif'
          host_node[:children] = []

          begin
            m.database_names[0]
          rescue Exception => e
            unless e.message.match(/unauthorized for db \[/).nil?
              f = e.message.join.split(/[\[\]]/)
              unless host[:username].nil? and f.length < 2
                m[f[1]].authenticate(host[:username], host[:password])
              end
            end
          end

          begin
            db_list = m.database_names
          rescue
            db_list = host[:collections]
          end

          db_list.each do |db_name|
              db = m.db(db_name)

              db_node = {}
              db_node[:id] = counter
              counter += 1
              db_node[:text] = db_name
              db_node[:icon] = 'images/db.gif'
              db_node[:children] = []

              begin
                collections = db.collection_names
              rescue Exception => e
                p e.message
                unless e.message.match(/unauthorized db:/).nil?
                  f = e.message.split(/[: ]/)
                  unless host[:username].nil? and f.length < 2
                    m[f[2]].authenticate(host[:username], host[:password])
                  end
                end
              end

              db.collection_names.each do |coll_name|
                  coll_node = {}
                  coll_node[:id] = counter
                  counter += 1
                  coll_node[:text] = coll_name
                  coll_node[:leaf] = true
                  db_node[:children] << coll_node
              end
              if db_node[:children].size == 0
                  db_node[:leaf] = true
              end
              host_node[:children] << db_node
          end
          data << host_node
          m.close
        rescue Exception => e
          p e
          puts "Could not connect to #{host[:host]}:#{host[:port]}"
          next
        end
    end

    return JSON.pretty_generate(data)
end


post '/query' do
    query = nil

    data = HOSTS[params['host']]
    query = JSON.parse(params['query']) if params.has_key?('query')

    db = Mongo::Connection.new( data[:host],
                                data[:port],
                                :slave_ok => true).db(params['db'])

    unless data[:username].nil?
      db.authenticate(data[:username], data[:password])
    end

    m = db.collection( params['coll'])

    rval = []
    if query == nil
        rval = m.find().limit(100).to_a 
    else
        rval =  m.find(query).limit(100).to_a 
    end

    return JSON.pretty_generate(rval) if rval.size
    return ""
end

post '/stats' do
  data = HOSTS[params['host']]
  
  db = Mongo::Connection.new( data[:host],
                              data[:port],
                              :slave_ok => true).db(params['db'])

  unless data[:username].nil?
    db.authenticate(data[:username], data[:password])
  end

  m = db.collection( params['coll'])
  return JSON.pretty_generate(m.stats)
end
