Rails.application.routes.draw do
  get 'download', to: 'home#download'
  get 'start', to: 'home#start'
  root 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
