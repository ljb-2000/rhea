Rhea::Engine.routes.draw do
  get '/', to: 'commands#index', as: 'rhea'
  resources :events, only: [:index]
  resources :hosts, only: [:index]
  resources :services, only: [:index]
  resources :commands, only: [:index, :create] do
    collection do
      get :delete
      post :update_all
    end
  end
  
  namespace 'api' do
    get '/jobs', to: 'jobs#index'
  end
end
