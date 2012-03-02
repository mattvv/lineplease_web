Lineplease::Application.routes.draw do
  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"
  get "faq" => "home#faq", :as => "faq"

  resources :users
  resources :sessions
  resources :scripts
  resources :home
  resources :conversions

  root :to => "home#index"
end
