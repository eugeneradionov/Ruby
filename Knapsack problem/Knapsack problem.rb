#Getting max weight of sack, number of items, value and weight for each item.
begin
  p 'Please enter max weight of sack: '
  $maxweight = gets.chop
  Integer($maxweight)
rescue
  p 'The number must be positive integer!'
  retry
end
$maxweight = $maxweight.to_i

begin
  p 'Please enter the number of items: '
  n = gets.chop
  Integer(n)
rescue
  p 'The number must be positive integer!'
  retry
end
n = n.to_i

$weight, $value = [], []
i =0
while i < n
  begin
      p 'Please enter the weight of item: '
      a = gets.chop
      Integer(a)
  rescue
      p 'The number must be positive integer!'
      retry
  end
  a = a.to_i

  begin
    p 'Please enter the value of item: '
    b = gets.chop
    Integer(b)
  rescue
    p 'The number must be positive integer!'
    retry
  end
  b = b.to_i

  $weight << a
  $value << b
  i+=1
end

#Calculating optimal solution
$all_weight, $all_value, i = 0, 0, 0
$max_values, $max_weights =[], []
loop do
  if i < n
    $all_weight+= $weight[i]
    $all_value+= $value[i]
    $max_values << $all_value
    $max_weights << $all_weight
    i+=1
    if $all_weight > $maxweight
      $all_weight -= $weight[i-1]
      $all_value -= $value[i-1]
    end
  else
    print 'Optimal values= ', $all_value, "\n", 'Optimal weight= ', $all_weight
    break
  end
end
