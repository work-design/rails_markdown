Rails.application.routes.draw do

  namespace :markdown, defaults: { business: 'markdown' } do
    resources :posts do
      collection do
        get '*path' => :show
      end
    end

    namespace :admin, defaults: { business: 'admin' } do
      resources :gits do
        resources :posts
      end
    end
  end

end
