Rails.application.routes.draw do
  get "/up", to: proc { [200, {}, ["OK"]] }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: "pages#home"
  devise_for :users

  get "quotes/pdf_status", to: "quotes#pdf_status"
  resources :quotes do
    resources :line_item_dates, except: [:index, :show] do
      resources :line_items, except: [:index, :show]
    end
    collection do
      post :generate_pdf
      get :pdf_status
    end
  end
end
