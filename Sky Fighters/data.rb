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
  max_count = -1
  for i in array_of_nations
    if max_count < i[1].to_i
      max_count = i[1].to_i
      country = i[0]
    end
  end
  if not country or country == 'Частные'
    'Другие'
    else
      country
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
    f.write("#{x.name},#{x.type},#{x.nation},#{x.epoch};\n")
  end
  f.close
  stop = Time.now
  time = stop - start
  p "Export to CSV: committed #{array.size} records in #{time.to_i} seconds"
end

def json_out(file_name, array)
  start = Time.now
  j = File.open(file_name, 'w')
  array.each{|x|
    j.write({ 'name'=> x.name, 'type' => x.type, 'nation' => x.nation, 'epoch' => x.epoch}.to_json)
  }
  j.close
  stop = Time.now
  time = stop - start
  p "Export to JSON: committed #{array.size} records in #{time.to_i} seconds"
end

base_url = 'http://wp.scn.ru'
wars = %w(ww1/ ww15/ ww2/ ww3/ ww4/)
planes_types = %w(f b a t o h s v)
planes = []
count_of_pages = 0

start_download = Time.now
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
    # Getting source code for planes
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

stop_download = Time.now
time_download = (stop_download - start_download).to_i

p "Fetched #{count_of_pages} pages in #{time_download} seconds."

#Output into csv and json files
csv_out('output.csv', planes)
json_out('jsonout.json', planes)