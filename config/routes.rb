Rails.application.routes.draw do

  namespace :markdown, defaults: { business: 'markdown' } do
    controller :assets do
      get 'posts/raw/assets/*path' => :asset, constraints: ->(req) { [:jpeg, :jpg, :png, :webp].include? req.format.symbol }
      get 'posts/assets/*path' => :asset, constraints: ->(req) { [:jpeg, :png, :webp].include? req.format.symbol }
      get 'assets/*path' => :asset, constraints: ->(req) { [:jpeg, :jpg, :png, :webp].include? req.format.symbol }
    end
    controller :posts do
      get 'markdowns/*path' => :show, constraints: ->(req) { [:md].include? req.format.symbol }
    end
    resources :posts, only: [:index] do
      collection do
        get :list
        get 'ppt/*path' => :ppt
        get 'raw/*path' => :raw
        get 'content/*path' => :content
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
