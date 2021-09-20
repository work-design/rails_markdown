Rails.application.routes.draw do

  namespace :markdown, defaults: { business: 'markdown' } do
    resources :posts, only: [:index] do
      member do
        get :ppt
      end
      collection do
        get '*path' => :asset, constraints: ->(req) { [:jpeg, :png, :webp].include? req.format.symbol }
        get '*path' => :show
        # get 'ppt/*path' => :ppt
      end
    end

    namespace :admin, defaults: { namespace: 'admin' } do
      resources :gits do
        resources :posts do
          collection do
            post :sync
          end
        end
      end
    end
  end

end
