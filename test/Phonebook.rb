require_relative 'PhoneBook_module.rb'
phonebook = {}

while TRUE
  print '
......
a - add phone
b - show names
c - clear phone book
g - show phone
i - import from file
r - remove phone
s - save phone book into the file
v - show phonebook
x - exit
......

'
  ans = gets().to_s.downcase!
  case ans
    when 'x'
      break
    when 'a'
      add(phonebook)
  end
end

