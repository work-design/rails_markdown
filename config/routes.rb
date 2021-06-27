Rails.application.routes.draw do

  namespace :markdown, defaults: { business: 'markdown' } do
    resources :posts

    namespace :admin, defaults: { business: 'admin' } do
      resources :gits do
        resources :posts
      end
    end

  end

end
