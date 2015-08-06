#!/usr/bin/ruby -w
# -*- encoding : utf-8 -*-
require 'net/http'
require 'uri'
require 'json'
require 'interface'
require 'pg'

load 'postgres_direct.rb'
load 'pattern_strategy.rb'

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