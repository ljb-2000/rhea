Rhea::Engine.routes.draw do
  get '/', to: 'workers#index', as: 'rhea'
  resources :hosts, only: [:index]
  resources :services, only: [:index]
  resources :workers, only: [:index] do
    collection do
      get :delete
      post :start
      post :update_all
    end
  end
  
  namespace 'api' do
    get '/jobs', to: 'jobs#index'
  end
end
