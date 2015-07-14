start = Time.now

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

  if country == nil
    return 'Другие'
  else
    return country
  end
end



wars = %w(ww1/ ww15/ ww2/ ww3/ ww4/)
planes_types = %w(f b a t o h s v)
planes = []
for war in wars

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
  for type in planes_types
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
    uri_planes = URI.parse('http://wp.scn.ru/ru/'+ war + type)
    response_planes = Net::HTTP.get(uri_planes)
    planes_regex = /<a\shref=(?<url>[^>]*)>(?<name>[^<]*)<\/a>\s?\[\d+\]<br>/
    all_planes = response_planes.force_encoding('windows-1251').encode('UTF-8').scan(planes_regex)

    #Array type of [<name>, <type>, <nation>, <epoch>, <URL>]
    for i in all_planes
      uri_nations = URI.parse('http://wp.scn.ru' + i[0])
      response_nations = Net::HTTP.get(uri_nations)
      nations_regex =/<img\sclass=img_bg[^.]*\.gif>\s<a\shref=[^>]*>(?<country>[^<]*)<\/a>\s?\[(?<count>\d+)\]/
      nation = best_nation(response_nations.force_encoding('windows-1251').encode('UTF-8').scan(nations_regex))
      planes << Planes.new(i[1], type_of_plane[type], nation, epoch, 'http://wp.scn.ru/'+i[0])
    end
  end
end

#Output into csv and json files
f = File.open('output.csv', 'w')
f.write("Name,Type,Nation,Epoch;\n")
j = File.open('jsonout.json', 'w')
planes.each{|x|
  f.write(x.name + "," + x.type + "," + x.nation + "," + x.epoch + ";\n")
  j.write({ 'name'=> x.name, 'type' => x.type, 'nation' => x.nation, 'epoch' => x.epoch}.to_json)
}
f.close
j.close

stop = Time.now
time = (stop - start)/60
p 'Runtime: %.2f minutes' % time