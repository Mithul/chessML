Rails.application.routes.draw do
  resources :games

  resources :users
  root to: 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  get '/games/:id/play' => 'games#play', as: :play
  get '/games/:id/move/:from' => 'games#check_move'
  get '/games/:id/move/:from/:to' => 'games#move'
end
