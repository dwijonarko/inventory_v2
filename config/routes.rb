ActionController::Routing::Routes.draw do |map|

  map.signin "signin", :controller => :user_sessions, :action => :new
  map.signout "signout", :controller => :user_sessions, :action => :destroy

  map.with_options(:controller => :pages, :action => :show) do |page|
    page.transactions 'transactions', :id => 'transactions'
    page.reports 'reports', :id => 'reports'
    page.administrations 'administrations', :id => 'administrations'
  end
  map.dashboard 'dashboard', :controller => :pages
  map.root :controller => :pages

  map.resources :user_sessions
  map.resources :items
  map.resources :categories do |category|
    category.resources :items
  end
  map.resources :companies
  map.resources :users

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
