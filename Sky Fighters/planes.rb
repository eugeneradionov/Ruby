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

$urls = [
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

$planes_regex = /<a\shref=(?<url>[^>]*)>(?<name>[^<]*)<\/a>\s?\[\d+\]<br>/
$nations_regex = /<img\sclass=img_bg[^.]*\.gif>\s<a\shref=[^>]*>(?<country>[^<]*)<\/a>\s?\[(?<count>\d+)\]/