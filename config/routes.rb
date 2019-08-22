Rails.application.routes.draw do




  get "users/:name", to: "users#show"

  resources :wildmons
  resources :pokemons
  resources :users

  
  post "/process-turn/:id", to: "users#process_turn"
  
  get "/start-three/:id", to: "pokemons#start_three"
  get "/kill-rejects/:id/:keeper", to: "users#kill_rejects"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
