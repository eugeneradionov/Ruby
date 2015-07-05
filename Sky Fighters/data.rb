require "net/http"
require "uri"

class Planes

  def initialize(name, type, nation, epoch, url)
    @name = name
    @type = type
    @nation = nation
    @epoh = epoch
    @url = url
  end

end

# Getting source code for planes
uri_planes = URI.parse("http://wp.scn.ru/ru/ww2/f")
response_planes = Net::HTTP.get(uri_planes)
#Net::HTTP.get_print(uri)
all_planes = response_planes.force_encoding("windows-1251").encode("UTF-8").scan(/<a\shref=(?<url>[^>]*)>(?<name>[^<]*)<\/a>\s?\[\d+\]<br>/)
all_nations = []

p all_planes

#Array type of [<nation>, <count of planes>]

for i in all_planes
  uri_nations = URI.parse("http://wp.scn.ru" + i[0])
  response_nations = Net::HTTP.get(uri_nations)
  all_nations << response_nations.force_encoding("windows-1251").encode("UTF-8").scan(/<img\sclass=img_bg[^.]*\.gif>\s<a\shref=[^>]*>(?<country>[^<]*)<\/a>\s?\[(?<count>\d)+\]/)
end


p all_nations
=begin
country = []
loop do
  i = 0
  max_count = '-1'
  begin
    get_nation = all_nations.shift
    get_nation.size
  rescue
    break
  end

  while i < get_nation.size
    if max_count < get_nation[i][1]
      country_tmp = get_nation[i][0]
      max_count = get_nation[i][1]
      country << [country_tmp]
    end
    i += 1
  end
end
p all_planes, country
=end