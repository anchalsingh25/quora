Rails.application.routes.draw do
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

  resources :answers, except: %i[show]

  resources :comments, except: %i[show update]

  resources :likes, only: [:create] do
    collection do
      delete :unlike
    end
  end

  resources :reports
  resources :punishments
end
