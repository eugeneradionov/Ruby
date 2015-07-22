def timer (start) 
  #Simple timer
  puts "Minutes: " + start.to_s
  start_time = Time.now
  puts start_time.strftime("Start_to_time: %I:%M:%S %p")
  start.downto(1) { sleep(60)}
  end_time = Time.now
  print end_time.strftime("Elapsed time: %I:%M:%S %p")
end

def alphabet
  #Print alphabet
  "a".upto("z") {|i| print i}
end

#Test department


require "net/http"
require "uri"
uri_planes = URI.parse("http://wp.scn.ru/ru/ww2/f")
response_planes = Net::HTTP.get(uri_planes)

#windows-1251
regex =/charset=\s+"/

=begin
require "net/http"
require "uri"

uri = URI.parse("http://wp.scn.ru/ru/ww2/f")
result = Net::HTTP.get(uri)

scan = result.force_encoding("windows-1251").encode("UTF-8").scan(/<a\shref=(?<url>[^>]*)>(?<name>[^<]*)<\/a>\s?\[\d+\]<br>/)

s = 'asddas/dasd/asd/as/da/"sd/"'
while s.include?('/')
  s['/'] = ' '
end
while s.include? (%Q("))
  s[%Q(")] = ''
end
p s
=end