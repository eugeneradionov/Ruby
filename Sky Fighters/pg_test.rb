#!/usr/bin/ruby -w
# -*- encoding : utf-8 -*-
require 'net/http'
require 'uri'
require 'json'
require 'interface'
require 'pg'

#Pattern strategy
OutputStrategy = interface {required_methods :use}

class JsonOut
  def use(file_name, array)
    start = Time.now
    begin
      j = File.open(file_name, 'w')
    rescue IOError
      return p 'I/O error!'
    rescue
      return p 'Oops :('
    end
    array.each{|x|
      j.write({ 'name'=> x.name, 'type' => x.type, 'nation' => x.nation, 'epoch' => x.epoch}.to_json)
    }
    j.close
    time = (Time.now - start).to_i
    p "Export to JSON: committed #{array.size} records in #{time} seconds"
  end
  implements OutputStrategy
end

class CsvOut
  def use(file_name, array)
    start = Time.now
    begin
      f = File.open(file_name, 'w')
      f.write("Name,Type,Nation,Epoch\n")
    rescue IOError
      return p 'I/O error!'
    rescue
      return p 'Oops :('
    end
    array.each do |x|
      x.name.gsub!('"', '""')
      f.write("\"#{x.name}\",\"#{x.type}\",\"#{x.nation}\",\"#{x.epoch}\"\n")
    end
    f.close
    time = (Time.now - start).to_i
    p "Export to CSV: committed #{array.size} records in #{time} seconds"
  end
  implements OutputStrategy
end

class PostgresDirect

  def connect(database_name)
    @conn = PG.connect(dbname: database_name, host: 'localhost', user: 'planes', password: '123', port: '5432')
  end

  def new_table
    @conn.exec("CREATE TABLE IF NOT EXISTS catalog (
id SERIAL PRIMARY KEY,
name TEXT NOT NULL,
type TEXT,
nation TEXT,
epoch TEXT);")
  end

  def clear_table
    @conn.exec("TRUNCATE catalog;")
  end

  def query(array)
    @conn.transaction do |c|
      array.each do |x|
        x.name.gsub!("'", "''")
        x.nation.gsub!("'", "''")
        c.exec( "INSERT INTO catalog (name, type, nation, epoch)
        VALUES ('#{x.name}','#{x.type}','#{x.nation}','#{x.epoch}')")
      end
    end
  end

  def disconnect
    @conn.close
  end
end

class PostgresqlOut

  def use(database_name, array)
    start = Time.now
    postgre_out = PostgresDirect.new
    postgre_out.connect(database_name)
    begin
      postgre_out.new_table
      postgre_out.clear_table
      postgre_out.query(array)
    rescue Exception => e
      p e.message
    ensure
      postgre_out.disconnect
    end
    time = (Time.now - start).to_i
    p "Export to PostgreSQL: committed #{array.size} records in #{time} seconds"
  end
  implements OutputStrategy
end

class Output
  attr_accessor :output_strategy
  def initialize (output_strategy)
    @output_strategy = output_strategy
  end
  def use_strategy(file_name, array)
    output_strategy.use(file_name, array)
  end
end

class Planes
  def initialize(name, type, nation, epoch, url)
    @name = name
    @type = type
    @nation = nation
    @epoch = epoch
    @url = url
  end
  attr_reader :name, :type, :nation, :epoch
end
urls = [
    ['http://wp.scn.ru/ru/ww3/h/', 'Sea', 'Cold War'],
]

planes_regex = /<a\shref=(?<url>[^>]*)>(?<name>[^<]*)<\/a>\s?\[\d+\]<br>/
nations_regex = /<img\sclass=img_bg[^.]*\.gif>\s<a\shref=[^>]*>(?<country>[^<]*)<\/a>\s?\[(?<count>\d+)\]/

def encoding_safe_response(url, encoding)
  begin
    uri_parse = URI.parse(url)
    response = Net::HTTP.get(uri_parse)
    result = response.dup.force_encoding(encoding)
    unless result.valid_encoding?
      result = response.encode(encoding, 'Windows-1251' )
    end
  rescue EncodingError
    result.encode!(encoding, invalid: :replace, undef: :replace )
  end
end

def best_nation(url, regex)
#Determines the best nation
  begin
    response_nations = encoding_safe_response(url,'UTF-8')
    array_of_nations = response_nations.scan(regex)
    return array_of_nations.max_by{|x| x.count.to_i}[0]
  rescue
    return 'Другие'
  end
end



start_download = Time.now
planes = []
count_of_pages = 0
urls.each do |plane|
  #Array type of [<URL>, <name>]
  all_planes = encoding_safe_response(plane[0],'UTF-8').scan(planes_regex)
  #Array type of [<name>, <type>, <nation>, <epoch>, <URL>]
  all_planes.each do |i|
    nation = best_nation(plane[0] + i[0].split('/')[-1], nations_regex)
    planes << Planes.new(i[1], plane[1], nation, plane[2], plane[0]+i[0])
    count_of_pages += 1
  end
end

time_download = (Time.now - start_download).to_i
p "Fetched #{count_of_pages} pages in #{time_download} seconds."

#Output into postgresql
output = Output.new(PostgresqlOut.new)
output.use_strategy('planes', planes)