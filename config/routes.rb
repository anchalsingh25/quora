Rails.application.routes.draw do
  get 'questions/show'
  get 'questions/update'
  get 'questions/destroy'

  resources :users, only: [] do
    collection do
      post :register
      post :login
      delete :logout
      delete '/me', to: 'users#delete_current_user'
      post :recover_account
    end
  end

  resources :questions do
    collection do
      get '/me', to: 'questions#user_questions'
    end
  end

  resources :answers, except: %i[show]

  resources :comments, except: %i[show update]

  resources :likes, only: [:create] do
    collection do
      delete :unlike
    end
  end
  
end
