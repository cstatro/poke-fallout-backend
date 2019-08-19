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

    def self.breed(mother, father, owner_id)

        # Determine Face

        face_id = self.chose_ancestor([mother, father].sample).face_id

        # Determine Body

        body_id = self.chose_ancestor([mother, father].sample).body_id

        # Get fusion data

        response = HTTParty.get("https://pokemon.alexonsager.net/#{face_id}/#{body_id}")
        data = Nokogiri::HTML(response)

        self.create(
            name: data.css("#pk_name").text,
            image_url: data.css("#pk_img").attr("src"),
            face_id: face_id,
            body_id: body_id,
            mother_id: mother.id,
            father_id: father.id,
            gender: ["male", "female"].sample,
            owner_id: owner_id
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
 