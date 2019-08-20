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
        user.update(name: name.downcase)
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

    private 
    def user_params
        params.require(:user).permit(:name)
    end
end
