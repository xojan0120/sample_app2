def cnt(model)
  puts "#{model.to_s} => #{model.count}"
end

[User,Relationship,Micropost,DirectMessage,DirectMessageStat,UserRoom].each do |model|
  cnt(model)
end
