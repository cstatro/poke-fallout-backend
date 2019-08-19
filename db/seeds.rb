# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.destroy_all 
User.create(name:"Ash")
User.create(name:"Brock")

# Pokemon.destroy_all

# (1..151).to_a.each do |index|
#     Pokemon.create(face_id: index, body_id: index, gender: "male", level: 1, loyalty: 50)
# end

# (1..151).to_a.each do |index|
#     Pokemon.create(face_id: index, body_id: index, gender: "female", level: 1, loyalty: 50)
# end