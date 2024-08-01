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
      delete '/me', to: 'users#delete_current_user'
    end
  end

  resources :questions do
    collection do
      get '/me', to: 'questions#user_questions'
    end
  end

  resources :answers, except: %i[index show]
end
