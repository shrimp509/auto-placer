Rails.application.routes.draw do
  get 'lease/index'
  get 'lease/start'
  get 'lease/download'

  get 'download', to: 'home#download'
  get 'start', to: 'home#start'
  root 'home#index'
end
