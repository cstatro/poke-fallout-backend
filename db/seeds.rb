# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.destroy_all 
User.create(name:"ash")
User.create(name:"brock")

# Pokemon.destroy_all

# (1..151).to_a.each do |index|
#     Pokemon.create(face_id: index, body_id: index, gender: "male", level: 1, loyalty: 50)
# end

# (1..151).to_a.each do |index|
#     Pokemon.create(face_id: index, body_id: index, gender: "female", level: 1, loyalty: 50)
# end






# Create Wildmon


def find_level_in_evo(poke_id, data)

    check = data.evolves_to.find{|evo| evo.species.url.split("/").last.to_i == poke_id}

    if check 
        if check.evolution_details[0].min_level
            check.evolution_details[0].min_level
        else
            40
        end
    else
        find_level_in_evo(poke_id, data.evolves_to[0])
    end

end

Wildmon.destroy_all


(1..151).to_a.each do |id|

    species = PokeApi.get(pokemon_species: id)

    

    if species.evolves_from_species == nil
        min_lev = 1
    else
        evo_id = species.evolution_chain.url.split("/").last.to_i
        evolution_chain = PokeApi.get(evolution_chain: evo_id)
        min_lev = find_level_in_evo(id, evolution_chain.chain)
    end

    Wildmon.create(species_id: id, habitat: species.habitat.name, minimum_level: min_lev, capture_rate: species.capture_rate)
          
    
end