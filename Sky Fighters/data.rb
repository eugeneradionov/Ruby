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

class PostgresqlOut
  def use(database_name, array)
    start = Time.now
    conn = PG.connect(dbname: database_name)
    conn.exec("CREATE TABLE IF NOT EXISTS catalog (
id SERIAL PRIMARY KEY,
name TEXT NOT NULL,
type TEXT,
nation TEXT,
epoch TEXT);")
    conn.exec("TRUNCATE catalog;")
    array.each do |x|
      x.name.gsub!('"', '""')
      conn.transaction do |c|
        c.exec( "INSERT INTO catalog (name, type, nation, epoch)
        VALUES '#{x.name}','#{x.type}','#{x.nation}','#{x.epoch}';")
      end
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
    ['http://wp.scn.ru/ru/ww1/f/', 'Fighter', 'World War I'],
    ['http://wp.scn.ru/ru/ww1/b/', 'Bomber', 'World War I'],
    ['http://wp.scn.ru/ru/ww1/a/', 'Attack', 'World War I'],
    ['http://wp.scn.ru/ru/ww1/t/', 'Transport', 'World War I'],
    ['http://wp.scn.ru/ru/ww1/o/', 'Other', 'World War I'],
    ['http://wp.scn.ru/ru/ww1/h/', 'Sea', 'World War I'],
    ['http://wp.scn.ru/ru/ww1/s/', 'Special', 'World War I'],
    ['http://wp.scn.ru/ru/ww1/v/', 'Helicopter', 'World War I'],
    ['http://wp.scn.ru/ru/ww15/f/', 'Fighter', 'Interwar'],
    ['http://wp.scn.ru/ru/ww15/b/', 'Bomber', 'Interwar'],
    ['http://wp.scn.ru/ru/ww15/a/', 'Attack', 'Interwar'],
    ['http://wp.scn.ru/ru/ww15/t/', 'Transport', 'Interwar'],
    ['http://wp.scn.ru/ru/ww15/o/', 'Other', 'Interwar'],
    ['http://wp.scn.ru/ru/ww15/h/', 'Sea', 'Interwar'],
    ['http://wp.scn.ru/ru/ww15/s/', 'Special', 'Interwar'],
    ['http://wp.scn.ru/ru/ww15/v/', 'Helicopter', 'Interwar'],
    ['http://wp.scn.ru/ru/ww2/f/', 'Fighter', 'World War II'],
    ['http://wp.scn.ru/ru/ww2/b/', 'Bomber', 'World War II'],
    ['http://wp.scn.ru/ru/ww2/a/', 'Attack', 'World War II'],
    ['http://wp.scn.ru/ru/ww2/t/', 'Transport', 'World War II'],
    ['http://wp.scn.ru/ru/ww2/o/', 'Other', 'World War II'],
    ['http://wp.scn.ru/ru/ww2/h/', 'Sea', 'World War II'],
    ['http://wp.scn.ru/ru/ww2/s/', 'Special', 'World War II'],
    ['http://wp.scn.ru/ru/ww2/v/', 'Helicopter', 'World War II'],
    ['http://wp.scn.ru/ru/ww3/f/', 'Fighter', 'Cold War'],
    ['http://wp.scn.ru/ru/ww3/b/', 'Bomber', 'Cold War'],
    ['http://wp.scn.ru/ru/ww3/a/', 'Attack', 'Cold War'],
    ['http://wp.scn.ru/ru/ww3/t/', 'Transport', 'Cold War'],
    ['http://wp.scn.ru/ru/ww3/o/', 'Other', 'Cold War'],
    ['http://wp.scn.ru/ru/ww3/h/', 'Sea', 'Cold War'],
    ['http://wp.scn.ru/ru/ww3/s/', 'Special', 'Cold War'],
    ['http://wp.scn.ru/ru/ww3/v/', 'Helicopter', 'Cold War'],
    ['http://wp.scn.ru/ru/ww4/f/', 'Fighter', 'Modern'],
    ['http://wp.scn.ru/ru/ww4/b/', 'Bomber', 'Modern'],
    ['http://wp.scn.ru/ru/ww4/a/', 'Attack', 'Modern'],
    ['http://wp.scn.ru/ru/ww4/t/', 'Transport', 'Modern'],
    ['http://wp.scn.ru/ru/ww4/o/', 'Other', 'Modern'],
    ['http://wp.scn.ru/ru/ww4/h/', 'Sea', 'Modern'],
    ['http://wp.scn.ru/ru/ww4/s/', 'Special', 'Modern'],
    ['http://wp.scn.ru/ru/ww4/v/', 'Helicopter', 'Modern'],
    ['http://wp.scn.ru/ru/ww4/d/', 'Drone', 'Modern']
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
#Output into csv and json files
output = Output.new(CsvOut.new)
output.use_strategy('output.csv', planes)

output = Output.new(JsonOut.new)
output.use_strategy('jsonout.json', planes)

#Output to postgresql
output = Output.new(PostgresqlOut.new)
output.use_strategy('planes',planes)