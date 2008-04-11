ActionController::Routing::Routes.draw do |map|
  map.home '', :controller => 'forums', :action => 'index'

  map.resources :sessions
  
  map.resources :blogs, :collection => {:reset => :get}
  
  map.resources :aggregator
  
  map.resources :users, :member => { :admin => :post } do |user|
    user.resources :moderators
  end
  
  map.resources :forums do |forum|
    forum.resources :topics do |topic|
      topic.resources :posts
    end
  end

  map.resources :posts, :name_prefix => 'all_'

  %w(user forum).each do |attr|
    map.resources :posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id"
  end

  map.blogosfera '/blogosfera.rss', :controller => 'blogs', :action => 'blogosphere', :format => 'rss'
  map.blogosfera '/blogosfera', :controller => 'blogs', :action => 'blogosphere'
  map.preview_topic '/topics/preview', :controller => "topics", :action => "preview"
  map.signup '/signup',     :controller => 'users',    :action => 'new'
  map.settings '/settings', :controller => 'users',    :action => 'edit'
  map.login  '/login',      :controller => 'sessions', :action => 'new'
  map.logout '/logout',     :controller => 'sessions', :action => 'destroy'
  map.connect ':controller/:action/:id'
  
end
