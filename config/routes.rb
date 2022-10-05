Rails.application.routes.draw do

  namespace :markdown, defaults: { business: 'markdown' } do
    resources :posts, only: [:index] do
      member do
        get :ppt
        get :content
      end
      collection do
        get :list
        get '*path' => :asset, constraints: ->(req) { [:jpeg, :png, :webp].include? req.format.symbol }
        get '*path' => :show
        # get 'ppt/*path' => :ppt
      end
    end

    namespace :admin, defaults: { namespace: 'admin' } do
      root 'home#index'
      resources :gits do
        resources :catalogs do
          member do
            patch :reorder
          end
        end
        resources :posts do
          collection do
            post :sync
          end
        end
      end
    end
  end

end
