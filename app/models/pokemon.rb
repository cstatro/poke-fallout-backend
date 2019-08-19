class Pokemon < ApplicationRecord

    belongs_to :mother, class_name: "Pokemon", optional: true
    belongs_to :father, class_name: "Pokemon", optional: true

    has_many :mothers_children, class_name: "Pokemon", foreign_key: :mother_id
    has_many :fathers_children, class_name: "Pokemon", foreign_key: :father_id

    def children
        if self.gender == "male"
            self.fathers_children
        else
            self.mothers_children
        end
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

    def self.speciesInfo(species_id)

        pokemon_call = PokeApi.get(pokemon: species_id)
        species_call = PokeApi.get(pokemon_species: species_id)
        evolution_call = PokeApi.get(evolution_chain: species_call.evolution_chain.url.split("/").last.to_i)
    
        evolution_data = self.find_in_evo_chain(pokemon_call.species.name, [evolution_call.chain])
        {
            name: pokemon_call.species.name,
            base_stats: pokemon_call.stats.each_with_object({}){|stat, hash| hash[stat.stat.name] = stat.base_stat},
            types: pokemon_call.types.sort_by{|type| type.slot}.map{|type| type.type.name},
            capture_rate: species_call.capture_rate,
            evolutions: evolution_data.evolves_to.map{|datum| {to_id: datum.species.url.split("/").last.to_i , level: self.extended_min_level(datum)}}.filter{|evo| evo[:to_id] < 152},
            growth_rate: species_call.growth_rate.name,
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

        # puts self.speciesInfo(mother.face_id)
        # puts self.speciesInfo(mother.body_id)
        # puts self.speciesInfo(father.face_id)
        # puts self.speciesInfo(father.body_id)


        # Determine Level

        baseline = (mother.level + father.level)/2

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
        elsif (mother_2 & father_2).any?
            incest_factor = 2
        elsif (mother_3 & father_3).any?
            incest_factor = 1
        else
            incest_factor = 0
        end



        # Determine Face

        face_id = self.chose_ancestor([mother, father].sample).face_id

        # Determine Body

        body_id = self.chose_ancestor([mother, father].sample).body_id

        # Get fusion data

        response = HTTParty.get("https://pokemon.alexonsager.net/#{face_id}/#{body_id}")
        data = Nokogiri::HTML(response)

        self.create(
            level: [baseline + loyalty_factor - incest_factor, 1].max,
            name: data.css("#pk_name").text,
            image_url: data.css("#pk_img").attr("src"),
            face_id: face_id,
            body_id: body_id,
            mother_id: mother.id,
            father_id: father.id,
            gender: ["male", "female"].sample,
            user_id: user_id,
            loyalty: 50
        )

    end

    def self.test_breed
        grouped = self.all.partition{|poke| poke.gender=="male"}
        mother = grouped[1].sample
        father = grouped[0].sample
        self.breed(mother, father, 1)
    end

    def self.test
        mother = Pokemon.all[302..Pokemon.all.length].select{|poke, index| poke.gender == "female"}.sample
        puts mother.image_url
        puts mother.id
        father = Pokemon.all[302..Pokemon.all.length].select{|poke, index| poke.gender == "male"}.sample
        puts father.image_url
        puts father.id
        new = self.breed(mother, father, 1)
        puts new.image_url
    end



end
 