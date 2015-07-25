require 'net/http'
require 'uri'
require 'json'

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

def best_nation(array_of_nations)
#Determines the best nation
  begin
    array_of_nations.max_by{|x| x[1].to_i}[0]
    return array_of_nations.max_by{|x| x[1].to_i}[0]
  rescue
    return 'Другие'
  end
end

def csv_out(file_name, array)
  start = Time.now
  f = File.open(file_name, 'w')
  f.write("Name,Type,Nation,Epoch\n")
  array.each do |x|
    if x.name.include?('/')
      x.name.gsub!('/', ' ')
    elsif x.name.include? ('"')
      x.name.gsub!('"', '""')
    end
    f.write("\"#{x.name}\",\"#{x.type}\",\"#{x.nation}\",\"#{x.epoch}\"\n")
  end
  f.close
  time = (Time.now - start).to_i
  p "Export to CSV: committed #{array.size} records in #{time} seconds"
end

def json_out(file_name, array)
  start = Time.now
  j = File.open(file_name, 'w')
  array.each{|x|
    j.write({ 'name'=> x.name, 'type' => x.type, 'nation' => x.nation, 'epoch' => x.epoch}.to_json)
  }
  j.close
  time = (Time.now - start).to_i
  p "Export to JSON: committed #{array.size} records in #{time} seconds"
end

=begin
planes = []
base_url = 'http://wp.scn.ru'
wars = %w(ww1/ ww15/ ww2/ ww3/ ww4/)
planes_types = %w(f b a t o h s v)

count_of_pages = 0
wars.each do |war|
  case war
    when "ww1/"
      epoch = "World War I"
    when "ww15/"
      epoch = "Interwar"
    when "ww2/"
      epoch = "World War II"
    when "ww3/"
      epoch = "Cold war"
    when "ww4/"
      epoch = "Modern"
      planes_types = %w(f b a t o h s v d)
    else
      epoch = "Unknown"
  end
  planes_types.each do |type|
    type_of_plane = {"f" => "Fighter",
                     "b" => "Bomber",
                     "a" => "Attack",
                     "t" => "Transport",
                     "o" => "Other",
                     "h" => "Sea",
                     "s" => "Special",
                     "v" => "Helicopter",
                     "d" => "Drone"}
    #Array type of [<URL>, <name>]
    uri_planes = URI.parse("#{base_url}/ru/#{war}#{type}")
    response_planes = Net::HTTP.get(uri_planes)
    planes_regex = /<a\shref=(?<url>[^>]*)>(?<name>[^<]*)<\/a>\s?\[\d+\]<br>/
    all_planes = response_planes.force_encoding('windows-1251').encode('UTF-8').scan(planes_regex)
    count_of_pages += 1
    #Array type of [<name>, <type>, <nation>, <epoch>, <URL>]
    all_planes.each do |i|
      uri_nations = URI.parse(base_url + i[0])
      response_nations = Net::HTTP.get(uri_nations)
      nations_regex = /<img\sclass=img_bg[^.]*\.gif>\s<a\shref=[^>]*>(?<country>[^<]*)<\/a>\s?\[(?<count>\d+)\]/
      nation = best_nation(response_nations.force_encoding('windows-1251').encode('UTF-8').scan(nations_regex))
      planes << Planes.new(i[1], type_of_plane[type], nation, epoch, base_url+i[0])
      count_of_pages += 1
    end
  end
end
=end
start_download = Time.now
planes = []
count_of_pages = 0
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
urls.each do |plane|
  #Array type of [<URL>, <name>]
  uri_planes = URI.parse(plane[0])
  response_planes = Net::HTTP.get(uri_planes)
  planes_regex = /<a\shref=(?<url>[^>]*)>(?<name>[^<]*)<\/a>\s?\[\d+\]<br>/
  all_planes = response_planes.force_encoding('windows-1251').encode('UTF-8').scan(planes_regex)
  all_planes.each do |i|
    #Array type of [<name>, <type>, <nation>, <epoch>, <URL>]
    uri_nations = URI.parse(plane[0] + i[0].split('/')[-1])
    response_nations = Net::HTTP.get(uri_nations)
    nations_regex = /<img\sclass=img_bg[^.]*\.gif>\s<a\shref=[^>]*>(?<country>[^<]*)<\/a>\s?\[(?<count>\d+)\]/
    nation = best_nation(response_nations.force_encoding('windows-1251').encode('UTF-8').scan(nations_regex))
    planes << Planes.new(i[1], plane[1], nation, plane[2], plane[0]+i[0])
    count_of_pages += 1
  end
end

time_download = (Time.now - start_download).to_i
p "Fetched #{count_of_pages} pages in #{time_download} seconds."
#Output into csv and json files
csv_out('output.csv', planes)
json_out('jsonout.json', planes)