Kuroko2::Engine.routes.draw do
  resources :job_definitions, path: 'definitions' do
    get 'page/:page', action: :index, on: :collection, as: 'paged'
    resources :stars, only: %w(create destroy)
    resources :job_instances, path: 'instances', only: %w(index create show destroy) do
      get 'naked', action: :show, on: :member, mode: :naked
      get 'page/:page', action: :index, on: :collection, as: 'paged'
      delete 'force_destroy', action: :force_destroy, on: :member
      resources :tokens, only: %w(index update)
      resources :executions, only: %w(destroy)
      resources :logs, only: %w(index)
      resources :execution_logs, only: %w(index)
    end
    resources :job_schedules, path: 'schedules', only: %w(index create destroy)
    resources :job_suspend_schedules, path: 'suspend_schedules', only: %w(index create destroy)
    resources :job_definition_stats, path: 'stats', only: %w(index) do
      get :memory, action: :memory, on: :collection, defaults: { format: 'json' }
      get :execution_time, action: :execution_time, on: :collection, defaults: { format: 'json' }
    end
  end
  resources :users do
    get 'page/:page', action: :index, on: :collection, as: 'paged'
  end

  resources :workers, only: %i(index update)
  resources :job_instances, path: 'instances', only: %w() do
    get :working, action: :working, on: :collection
  end
  resources :executions, only: %i(index)

  resources :job_timelines, only: :index do
    get :dataset, action: :dataset, on: :collection, defaults: { format: 'json' }
  end

  get '/sign_in', to: 'sessions#new', as: 'sign_in'
  delete '/sign_out', to: 'sessions#destroy', as: 'sign_out'

  get '/auth/:provider', as: :auth, to: lambda { |_env| [500, {}, 'Never called'] }
  get '/auth/:provider/callback', to: 'sessions#create'

  root 'dashboard#index'
  get '/osd' => 'dashboard#osd', as: :osd

  scope :v1, module: 'api', as: 'api' do
    resources :job_definitions, path: 'definitions', only: %w(create show update) do
      resources :job_instances, path: 'instances', only: %w(show create)
    end

    namespace :stats do
      get :instance
      get :waiting_execution
    end
  end
end
