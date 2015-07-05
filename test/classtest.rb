class Repeat
  @@total = 0
  def initialize(string, times)
    @string = string
    @times = times
  end
  def repeat
    @@total += @times
    @string * @times
  end
  def total
    "Total times, so far: " + @@total.to_s
  end
end

class Area
  def Area.rect (length, width, units = 'inches')
    area = length * width
    printf("Area of rectangle is %.2f %s.", area, units)
    sprintf("%.2f%", area)
  end
end
Area.rect(12.5, 16)
a = Repeat.new('hi', 3)
p a.repeat
