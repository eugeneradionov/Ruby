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
x = Planes.new("name", "type", "nation", "epoch", "url")

p x.name, x.type, x.nation, x.epoch
#"name", "type", "nation", "epoch", "url"