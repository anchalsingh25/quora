Rails.application.routes.draw do
  get 'questions/show'
  get 'questions/update'
  get 'questions/destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :users, only: [] do
    collection do
      post :register
      post :login
      delete :logout
    end
  end

  resources :questions
end
