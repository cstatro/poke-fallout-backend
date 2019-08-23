class Pokemon < ApplicationRecord

    @@habitats = ["cave", "forest", "grassland", "mountain", "rough-terrain", "sea", "urban", "waters-edge"]

    belongs_to :mother, class_name: "Pokemon", optional: true
    belongs_to :father, class_name: "Pokemon", optional: true
    belongs_to :user 

    has_many :mothers_children, class_name: "Pokemon", foreign_key: :mother_id
    has_many :fathers_children, class_name: "Pokemon", foreign_key: :father_id







    def children
        if self.gender == "male"
            self.fathers_children
        else
            self.mothers_children
        end
    end

    def types
        [self.face_type, self.body_type].compact
    end



    def self.X_parents(generation, pokemon)
        parents = [pokemon.mother, pokemon.father].compact
        if generation == 1
            parents
        else
            parents.flat_map{|parent| X_parents(generation - 1, parent)}
        end
    end

    # Species Info Lookup

    def self.find_in_evo_chain(name, data_array)
        name_check = data_array.find{|datum| datum.species.name == name}
        if name_check
            name_check
        else
            self.find_in_evo_chain(name, data_array.flat_map{|datum| datum.evolves_to})
        end
    end
    
    def self.extended_min_level(datum)
        level = datum.evolution_details[0].min_level
        if level
            level
        else
            40
        end
    end


    # PokeApi Info

    def self.speciesInfo(species_id)
        pokemon_call = PokeApi.get(pokemon: species_id)
        species_call = PokeApi.get(pokemon_species: species_id)
        evolution_call = PokeApi.get(evolution_chain: species_call.evolution_chain.url.split("/").last.to_i)
        
        evolution_data = self.find_in_evo_chain(pokemon_call.species.name, [evolution_call.chain])

        if species_call.growth_rate.name == "slow"
            rate_number = 0.25
        elsif species_call.growth_rate.name == "medium-slow"
            rate_number = 0.5
        elsif species_call.growth_rate.name == "medium"
            rate_number = 0.75
        else
            rate_number = 1
        end
        
        {
            name: pokemon_call.species.name,
            base_stats: pokemon_call.stats.each_with_object({}){|stat, hash| hash[stat.stat.name] = stat.base_stat},
            types: pokemon_call.types.sort_by{|type| type.slot}.map{|type| type.type.name},
            capture_rate: species_call.capture_rate,
            evolutions: evolution_data.evolves_to.map{|datum| {to_id: datum.species.url.split("/").last.to_i , level: self.extended_min_level(datum)}}.filter{|evo| evo[:to_id] < 152},
            growth_rate: rate_number,
            habitat: species_call.habitat.name
        }
        
    end


    def self.chose_ancestor(pokemon)
        if [true, false].sample
            pokemon
        else
            parents = [pokemon.mother, pokemon.father].compact
            if parents == []
                pokemon
            else
                self.chose_ancestor(parents.sample)
            end
        end
    end



    def self.breed(mother, father, user_id)

        # Determine Rough Kind of Resulting Pokemon

        basis_face_id = self.chose_ancestor([mother, father].sample).face_id
        basis_body_id = self.chose_ancestor([mother, father].sample).body_id

        face_info = self.speciesInfo(basis_face_id)
        body_info = self.speciesInfo(basis_body_id)



        # Determine Level

        baseline = (mother.level + father.level)/2

        # Growth Factor

        growth_ratio = (face_info[:growth_rate] + body_info[:growth_rate])/2

        rando = rand

        if growth_ratio > rando
            ease_factor = 1
        else
            ease_factor = 0
        end


        # Float from 0 to 1
        loyalty_ratio = (mother.loyalty + father.loyalty)/200.0

        rand_1 = rand

        rand_2 = rand

        if loyalty_ratio < [rand_1, rand_2].min
            loyalty_factor = -1
        elsif loyalty_ratio > [rand_1, rand_2].max
            loyalty_factor = 1
        else
            loyalty_factor = 0
        end

        mother_1 = self.X_parents(1, mother)
        mother_2 = mother_1.concat(self.X_parents(2, mother))
        mother_3 = mother_2.concat(self.X_parents(3, mother))

        father_1 = self.X_parents(1, father)
        father_2 = father_1.concat(self.X_parents(2, father))
        father_3 = father_2.concat(self.X_parents(3, father))

        if (mother_1 & father_1).any?
            incest_factor = 3
            print "Super creepy"
        elsif (mother_2 & father_2).any?
            incest_factor = 2
            print "Creepy"
        elsif (mother_3 & father_3).any?
            incest_factor = 1
            print "Still kinda creepy"
        else
            incest_factor = 0
            print "No incest detected"
        end

        level = [[baseline + ease_factor + loyalty_factor - incest_factor, 1].max, 99].min


        # Determine Face (accounting for possible evolution)

        evolutions = face_info[:evolutions].select{|evo_datum| evo_datum[:level] <= level}

        if evolutions.length > 0
            face_id = evolutions.sample[:to_id]
            face_info = self.speciesInfo(face_id)
        else
            face_id = basis_face_id
        end

        # Determine Body (accounting for possible evolution)

        evolutions = body_info[:evolutions].select{|evo_datum| evo_datum[:level] <= level}

        if evolutions.length > 0
            body_id = evolutions.sample[:to_id]
            body_info = self.speciesInfo(body_id)
        else
            body_id = basis_body_id
        end


        # Determine Stats

        hp = ((face_info[:base_stats]["hp"] + body_info[:base_stats]["hp"]) * level / 100) + 10 + level
        attack = ((face_info[:base_stats]["attack"] + body_info[:base_stats]["attack"]) * level / 100) + 5
        defense = ((face_info[:base_stats]["defense"] + body_info[:base_stats]["defense"]) * level / 100) + 5
        special_attack = ((face_info[:base_stats]["special-attack"] + body_info[:base_stats]["special-attack"]) * level / 100) + 5
        special_defense = ((face_info[:base_stats]["special-defense"] + body_info[:base_stats]["special-defense"]) * level / 100) + 5
        speed = ((face_info[:base_stats]["speed"] + body_info[:base_stats]["speed"]) * level / 100) + 5


        # Get fusion data

        response = HTTParty.get("https://pokemon.alexonsager.net/#{face_id}/#{body_id}")
        data = Nokogiri::HTML(response)

        newbie = self.create(
            level: level,
            name: data.css("#pk_name").text,
            image_url: data.css("#pk_img").attr("src"),
            face_id: face_id,
            body_id: body_id,
            mother_id: mother.id,
            father_id: father.id,
            face_type: face_info[:types][0],
            body_type: body_info[:types][0],
            gender: ["male", "female"].sample,
            user_id: user_id,
            loyalty: 50,
            hp: hp,
            attack: attack,
            defense: defense,
            special_attack: special_attack,
            special_defense: special_defense,
            speed: speed,
            alive: true,
            current_hp: hp,
            nourishment: 50
        )
        newbie
    end


    def self.generate(face_id, body_id, level, user_id)
        face_info = self.speciesInfo(face_id)
        body_info = self.speciesInfo(body_id)

        hp = ((face_info[:base_stats]["hp"] + body_info[:base_stats]["hp"]) * level / 100) + 10 + level
        attack = ((face_info[:base_stats]["attack"] + body_info[:base_stats]["attack"]) * level / 100) + 5
        defense = ((face_info[:base_stats]["defense"] + body_info[:base_stats]["defense"]) * level / 100) + 5
        special_attack = ((face_info[:base_stats]["special-attack"] + body_info[:base_stats]["special-attack"]) * level / 100) + 5
        special_defense = ((face_info[:base_stats]["special-defense"] + body_info[:base_stats]["special-defense"]) * level / 100) + 5
        speed = ((face_info[:base_stats]["speed"] + body_info[:base_stats]["speed"]) * level / 100) + 5

        # Get fusion data
        response = HTTParty.get("https://pokemon.alexonsager.net/#{face_id}/#{body_id}")
        data = Nokogiri::HTML(response)

        self.create(
            level: level,
            name: data.css("#pk_name").text,
            image_url: data.css("#pk_img").attr("src"),
            face_id: face_id,
            body_id: body_id,
            face_type: face_info[:types][0],
            body_type: body_info[:types][0],
            mother_id: nil,
            father_id: nil,
            gender: ["male", "female"].sample,
            user_id: user_id,
            loyalty: 50,
            hp: hp,
            attack: attack,
            defense: defense,
            special_attack: special_attack,
            special_defense: special_defense,
            speed: speed,
            alive: true,
            current_hp: hp,
            nourishment: 50
        )
    end




    def self.generate_starters(user_id)

        loc = @@habitats.sample

        others = Wildmon.inhabitants_by_level(loc, 5)
        grass = [1, others.sample.species_id].shuffle
        fire = [4, others.sample.species_id].shuffle
        water = [7, others.sample.species_id].shuffle
        [self.generate(grass[0], grass[1], 5, user_id), self.generate(fire[0], fire[1], 5, user_id), self.generate(water[0], water[1], 5, user_id)]
    end

   
    def self.random_poke
        mother = Pokemon.all.select{|poke, index| poke.gender == "female"}.sample
        puts mother.image_url
        puts mother.level
        father = Pokemon.all.select{|poke, index| poke.gender == "male"}.sample
        puts father.image_url
        puts father.level
        new = self.breed(mother, father, 5)
        puts new.image_url
        puts new.level
    end


    


    def collect_food_for(user)
        user.update(food: user.food + self.speed)
        puts "GETTING FOOD"
    end


    def food_baseline
        5 + (self.level / 5) 
    end

    def update_nourishment(food)
        ratio = (food - self.food_baseline)/self.food_baseline.to_f
        final = [[ratio * 15, 0.0].max.ceil, 100].min
        self.update(nourishment: final)
    end

    def eat_lots(user)
        eaten = [self.food_baseline * 2, user.food].min
        user.update(food: user.food - eaten)
        update_nourishment(eaten)
    end

    def eat_normal(user)
        eaten = [self.food_baseline, user.food].min
        user.update(food: user.food - eaten)
        update_nourishment(eaten)
    end

    def eat_little(user)
        eaten = [self.food_baseline / 2, user.food].min
        user.update(food: user.food - eaten)
        update_nourishment(eaten)
    end


    
    def self.generate_caught_pokemon

    end





end
 