require "net/http"
require "uri"

class Planes
  #attr_accessor name, type, nation, epoch, url
  def initialize(name, type, nation, epoch, url)
    @name = name
    @type = type
    @nation = nation
    @epoch = epoch
    @url = url
  end

  def self.all
    ObjectSpace.each_object(self).to_a
  end

  def self.count
    all.count
  end
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
  max_count = -1
  if country == nil
    return "Другие"
  else
    return country
  end
end



wars = %w(ww1/ ww15/ ww2/ ww3/ ww4/)
#wars = %w(ww1/ ww15/)
planes_types = %w(f b a t o h s v)
x = 0
for war in wars
  for type in planes_types

    case  war
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
        planes_types << "d"
      else
        epoch = "Unknown"
    end

    case  type
      when "f"
        type_of_plane = "Fighter"
      when "b"
        type_of_plane = "Bomber"
      when "a"
        type_of_plane = "Attack"
      when "t"
        type_of_plane = "Transport"
      when "o"
        type_of_plane = "Other"
      when "h"
        type_of_plane= "Sea"
      when "s"
        type_of_plane = "Special"
      when "v"
        type_of_plane = "Helicopter"
      when "d"
        type_of_plane = "Drone"
      else
        type_of_plane = "Unknown"
    end
    # Getting source code for planes
    uri_planes = URI.parse("http://wp.scn.ru/ru/"+ war + type)
    response_planes = Net::HTTP.get(uri_planes)
    #Net::HTTP.get_print(uri)
    all_planes = response_planes.force_encoding("windows-1251").encode("UTF-8").scan(/<a\shref=(?<url>[^>]*)>(?<name>[^<]*)<\/a>\s?\[\d+\]<br>/)
    all_nations = []

    #Array type of [<nation>, <count of planes>]
    m = 1
    planes = []
    for i in all_planes
      uri_nations = URI.parse("http://wp.scn.ru" + i[0])
      response_nations = Net::HTTP.get(uri_nations)
      scanregex = /<img\sclass=img_bg[^.]*\.gif>\s<a\shref=[^>]*>(?<country>[^<]*)<\/a>\s?\[(?<count>\d+)\]/
      nation = best_nation(response_nations.force_encoding("windows-1251").encode("UTF-8").scan(scanregex))
      all_nations << nation
      planes << Planes.new(i[1], type_of_plane, nation, epoch, 'http://wp.scn.ru/ru/ww2/f'+i[0])
      m += 1
    end
  end
  x += 1
  p x, Time.now
end
p all_planes, all_nations, planes