class PokemonsController < ApplicationController
    def start_three
        starters = Pokemon.generate_starters(params[:id])
        render json: PokemonsSerializer.new(starters)
    end
end
