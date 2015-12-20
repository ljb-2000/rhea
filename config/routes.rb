Rhea::Engine.routes.draw do
  get '/', to: 'commands#index', as: 'rhea'
  resources :commands, only: [:index, :create] do
    collection do
      get :delete
      get :redeploy
      get :reschedule
      get :stop
      post :batch_update
    end
  end
  resources :events, only: [:index]
  resources :nodes, only: [:index]
  resources :services, only: [:index]

  namespace 'api' do
    get '/jobs', to: 'jobs#index'
  end
end
