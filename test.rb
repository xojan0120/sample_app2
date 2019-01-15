
#aaa = -> x { x * 5 }
#
#p aaa.call(3)

options = { a: 1, b: 2 }

case options
when { a: 2, b: 2 }
  p options
end
