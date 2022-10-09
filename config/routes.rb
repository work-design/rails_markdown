Rails.application.routes.draw do

  namespace :markdown, defaults: { business: 'markdown' } do
    resources :posts, only: [:index] do
      collection do
        get :list
        get 'ppt/*path' => :ppt
        get 'raw/*path' => :raw
        get 'ppt/*path' => :ppt
        get 'content/*path' => :content
        get '*path' => :asset, constraints: ->(req) { [:jpeg, :png, :webp].include? req.format.symbol }
        get '*path' => :show
      end
    end
    resources :gits, only: [:show] do
      member do
        post '' => :create
      end
    end

    namespace :admin, defaults: { namespace: 'admin' } do
      root 'home#index'
      resources :gits do
        resources :catalogs do
          collection do
            get :all
          end
          member do
            patch :reorder
          end
        end
        resources :posts do
          collection do
            post :sync
          end
        end
        resources :assets do
          collection do
            post :sync
          end
        end
      end
    end
  end

end
