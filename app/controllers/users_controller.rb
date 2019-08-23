class UsersController < ApplicationController
    def index
        users = User.all
        render json: UsersSerializer.new(users)
    end

    def show
        user = User.find_by(name: params[:name].downcase)
        render json: UsersSerializer.new(user)
    end

    def create
        user = User.new(user_params)
        user.name = user.name.downcase
        user.update(facility_tier: 4)
        user.save
        render json: UsersSerializer.new(user)   
    end

    def kill_rejects
        keep = params[:keeper].to_i
        user = User.find(params[:id])
        user.pokemons.each do |p|
            if p.id != keep
                # byebug
                p.alive = false
                p.save
            end
        end
         survivor = user.pokemons.find {|p| p.alive == true}
         render json: PokemonsSerializer.new(survivor)
    end




    def process_turn

        user = User.find(params[:id])

        user.notifications.each{|note| note.destroy}


       

        # Update User Stats

        user.update(facility_tier: params[:facility_tier])
        user.update(authority: params[:authority])
        
        capacity = user.facility_tier * 2

        # This attaches the database pokemon object to the incoming data:
        pokemon = params[:pokemons].map do |data|
            data[:stored_object] = Pokemon.find(data[:id])
            data[:stored_object].update(food_policy: data[:food_policy])
            data[:stored_object].update(current_action: data[:current_action])
            data
        end


        poke_count = pokemon.length

        user.update(facility_cleanliness: params[:facility_cleanliness] - poke_count)

        
        if user.facility_cleanliness < 20

            Notification.create(text: "Your facilities are disgusting.", user_id: user.id)
            mess_factor = (20 - user.facility_cleanliness) / 4 # Used in loyalty calc below
        else
            mess_factor = 0
        end

        # Update Food collected
        pokemon.filter{|poke| poke[:current_action] == "Farming"}.each{|poke| poke[:stored_object].collect_food_for(user)}

        # Update Hunger
        pokemon.filter{|poke| poke[:food_policy] == 3}.each{|poke| poke[:stored_object].eat_lots(user)}
        pokemon.filter{|poke| poke[:food_policy] == 2}.each{|poke| poke[:stored_object].eat_normal(user)}
        pokemon.filter{|poke| poke[:food_policy] == 1}.each{|poke| poke[:stored_object].eat_little(user)}
        pokemon.filter{|poke| poke[:food_policy] == 0}.each{|poke| poke[:stored_object].update_nourishment(0)}

        if user.food < poke_count * 5
            Notification.create(text: "You're dangerously low on food.", user_id: user.id) 
        end


        # Hunger Consequences
        pokemon.each do |poke|
            if poke[:stored_object].nourishment < 20
                updated_hp = [[poke[:stored_object].current_hp - 20 + poke[:stored_object].nourishment, 0].max, poke[:stored_object].hp].min
                poke[:stored_object].update(current_hp: updated_hp)
                Notification.create(text: "#{poke[:stored_object].name} is dangerously hungry." , user_id: user.id)
            end
        end



        # Process exploration
        if poke_count < capacity

            explorers = pokemon.filter{|poke| poke[:current_action] == "Exploring"}

            explorers.each do |poke|

                puts "EXPLORING"

                if poke_count < capacity

                    location = ["cave", "forest", "grassland", "mountain", "rough-terrain", "sea", "urban", "waters-edge"].sample

                    # Slight cost to loyalty per explore

                    poke[:stored_object].update(loyalty: [poke[:stored_object].loyalty - 4, 0].max)

                    # add 1, 0, -1, or -2

                    spread = (rand * 4).floor - 1

                    level = [poke[:stored_object].level - spread, 1].max


                    # Get wild combination

                    opp = Wildmon.random_wild_data(location, level)

                    stats = Wildmon.check_stats(opp[:head_id], opp[:body_id], level)

                    puts stats[:attack]
                    puts stats[:defense]
                    puts poke[:stored_object].attack
                    puts poke[:stored_object].defense


                    # Chance for damage
                    
                    damage_base = [level + stats[:attack] - poke[:stored_object].defense, 0].max

                    damage = [(damage_base.to_f / poke[:stored_object].defense) * 10, 40.0].min.ceil

                    if damage > 0

                        poke[:stored_object].update(current_hp: poke[:stored_object].current_hp - damage)
                        Notification.create(text: "#{poke[:stored_object].name} took #{damage} damage while exploring.", user_id: user.id)
                        
                    end
                    

                    # Chance for capture

                    catch_base = [4 * poke[:stored_object].level + poke[:stored_object].attack - stats[:defense], 0].max

                    catch_rate = ([[5,     (catch_base.to_f / stats[:defense]) * 10    ].max, 100].min)/100.0

                    

                    rando = rand

                    puts rando
                    puts catch_rate

                    if catch_rate > rando
                        poke_count += 1
                        newbie = Pokemon.generate(opp[:head_id], opp[:body_id], level, params[:id])
                        Notification.create(text: "You caught a lv. #{level} #{newbie.name}.", user_id: user.id)
                    end

                end

            end
        
        end


        # Process Idle

        pokemon.filter{|poke| poke[:current_action] == "Idle"}.each do |poke|

            puts "IDLE"

            obj = poke[:stored_object]
            
            obj.update(loyalty: [obj.loyalty + 2, 100].min)

            if obj.current_hp > 0
                obj.update(current_hp: [obj.current_hp + (2 * obj.hp / 100.0).ceil, obj.hp].min)
            end

        end

        # Process births

        if poke_count < capacity

            gender_sorted = pokemon.filter{|poke| poke[:current_action] == "Breeding"}.partition{|poke| poke[:stored_object].gender == "male"}.sort_by{|ar| ar.length}

            gender_sorted[0].zip(gender_sorted[1]).each do |pair|

                if poke_count < capacity
                    puts "BREEDING"
                    ordered = pair.sort_by{|poke| poke[:stored_object].gender.length}
                    rando = rand
                    puts rando
                    if rando > 0.8
                        poke_count += 1
                        newborn = Pokemon.breed(ordered[0][:stored_object], ordered[1][:stored_object], params[:id])
                        Notification.create(text: "Your #{ordered[0][:stored_object].name} and #{ordered[1][:stored_object].name} sucessfully bred. You now have a lv. #{newborn.level} #{newborn.name}.", user_id: user.id)
                    end
                end
            end

        end

        # Process deaths (check at or below hp, kill and set hp to 0)

        death_count = 0

        pokemon.each do |poke|
            if poke[:stored_object].current_hp <= 0
                poke[:stored_object].alive = false
                Notification.create(text: "Your #{poke[:stored_object].name} died.", user_id: user.id)
                death_count += 1
            end
        end

        # Update Loyalty and Authority

        authority_accumulator = 0

        pokemon.each do |poke|

            obj = poke[:stored_object]

            if ((obj.current_hp * 100.0) / obj.hp.to_f) < 20.0
                damage_factor = 4
            else 
                damage_factor = 0
            end

            death_factor = death_count * 4

            loyalty_change = 0 - damage_factor - death_factor - mess_factor

            obj.update(loyalty: [[obj.loyalty + loyalty_change, 100].min, 0].max)

            authority_accumulator += obj.level * obj.loyalty / 100.0

        end

        user.update(authority: user.authority + authority_accumulator.ceil)


        
        render json: UsersSerializer.new(user)
    end




    private 
    def user_params
        params.require(:user).permit(:name)
    end



end
