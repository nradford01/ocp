Rails.application.routes.draw do
  resources :users

  resources :barcodes do
    collection do
      post :import
      get :generate
    end
  end

  root to: "pages#root"
end
