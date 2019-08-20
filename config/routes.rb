Rails.application.routes.draw do
  resources :wildmons
  resources :pokemons
  resources :users
  get "/start-three/:id", to: "pokemons#start_three"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
