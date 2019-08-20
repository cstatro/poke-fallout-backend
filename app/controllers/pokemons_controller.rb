class PokemonsController < ApplicationController
    def start_three
        starters = Pokemon.generate_starters(params[:id])
    end
end
