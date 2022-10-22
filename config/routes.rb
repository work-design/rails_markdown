Rails.application.routes.draw do
  FORMATS = [:jpeg, :jpg, :png, :webp, :svg, :mp4]
  namespace :markdown, defaults: { business: 'markdown' } do
    controller :assets do
      get 'posts/raw/assets/*path' => :asset, constraints: ->(req) { FORMATS.include? req.format.symbol }
      get 'posts/assets/*path' => :asset, constraints: ->(req) { FORMATS.include? req.format.symbol }
      get 'assets/*path' => :asset, constraints: ->(req) { FORMATS.include? req.format.symbol }
    end
    resources :posts, only: [:index] do
      collection do
        get :list
        get 'ppt/*path' => :ppt
        get 'raw/*path' => :raw
        get 'content/*path' => :content
        get '*slug' => :show
      end
    end
    controller :posts do
      # 这个定义必须在 resources :posts 后面，不然会影响 url_for action: 'show' 的参数解析
      get 'markdowns/*slug' => :show, defaults: { prefix: 'markdowns' }
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
