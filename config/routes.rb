Rails.application.routes.draw do
  resources :feedback, only: [:create]
end
