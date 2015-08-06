#!/usr/bin/ruby -w
# -*- encoding : utf-8 -*-
require 'net/http'
require 'uri'
require 'json'
require 'interface'
require 'pg'

load 'postgres_direct.rb'
load 'pattern_strategy.rb'
load 'planes.rb'


start_download = Time.now
planes = []
count_of_pages = 0
$urls.each do |plane|
  #Array type of [<URL>, <name>]
  all_planes = encoding_safe_response(plane[0],'UTF-8').scan($planes_regex)
  #Array type of [<name>, <type>, <nation>, <epoch>, <URL>]
  all_planes.each do |i|
    nation = best_nation(plane[0] + i[0].split('/')[-1], $nations_regex)
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