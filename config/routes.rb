Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists do
      resources :todo_items, path: :todoitems
    end
  end

  resources :todo_lists, only: %i[index new], path: :todolists do
    patch :update_all_items, on: :member
  end
end
