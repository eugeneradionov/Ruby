require 'json'

def add(vocabulary)
  k = gets 'Pleas enter the name: '
  p = gets 'Pleas enter the phone: '
  vocabulary[k] = p
end

def remove(vocabulary)
  r = gets 'Pleas enter the name: '
  if vocabulary.has_key?
    vocabulary.delete()
    p 'Job done!'
  end
end

def bshow(vocabulary)
  for k in vocabulary.keys.sort()
    print k
  end
end
