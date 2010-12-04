ActionController::Routing::Routes.draw do |map|
  map.namespace :inbox do |inbox|
    inbox.resources :messages, :except => [:edit, :update], :collection => {:unread => :get}, :member => {:reply => :get}
    inbox.resources :comments, :except => [:edit, :update], :collection => {:unread => :get}
    inbox.resources :notices, :only => [:index]
  end

  map.resources :users, :collection => {:unlink_user_accounts => :get, :link_user_accounts => :get, :delete_error => :get, :delete_confirm => :get, :activate => :get, :search => :get, :mutual_friends => :get,:export_csv => :get,:export_data_login_confirm=>:get ,:check_export_login=>:post, :private_user=>:post, :private_user_follow_request=>:get,:vanity_validation=>:get,:video_selection=>:get, :send_follow_request=>:get, :accept_or_reject_follow_request=>:get, :alpha_phase=>:get}, :member => { :invite => :post, :follow => :post } do |user|
    user.resource :favorites, :controller => "users/favorites", :collection=>{:show_before_unload=>:get}
    user.resource  :profile,   :controller => "users/profiles", :member => {:social_networks => :get, :delete_me => :get, :export_my_data => :get, :privacy=>:get, :change_privacy=>:put}
    user.resource  :password, :controller => "users/passwords", :only => [:edit, :update]
  end

  map.scope 'users/:user_id/profile/edit/:scope', :controller => 'users/profiles', :action => 'edit', :scope => :scope

  map.namespace :friends do |f|
    f.resource(:facebook)
    f.resource(:twitter, :member => { :auth => :get})
    f.resources(:contacts)
    f.resources(:invites)
  end

  map.resources :tips, :collection => {:list => :get, :vote => :post }

  map.namespace :apis do |api|
    api.resource(:twitter, :member => {:auth => :get, :unlink => :get, :tweet => :post })
  end
  
  map.resources :passwords
  map.resources :likes
  map.resource :session
  map.resources :categories
  map.resources :activities, :collection => {:more  => :get, :latest => :get, :show_latest => :get, :reply_form => :get}
  map.resources :pages
  map.resources :invites, :referrals, :member =>  {:resend => :get}
  map.resources :posts, :path_prefix => "blog", :collection => {:search => :post}
  # APP MARKER - Place app specific routes below this line
  map.connect "/h/:custom_item", :controller => "items", :action => "show"
  map.sub_item_categories "/items/sub_categories/:id", :controller => 'items', :action => 'sub_categories'
  map.additional_item_data "/items/additional_item_data/", :controller => 'items', :action => 'additional_item_data'
  
  map.resources :items, :member => {:refresh_images => :post, :graph => :get, :conversation_comment => [:post, :get], :trend => [:get], :favorite => [:post]}, 
                        :has_many => {:reviews => :peer_reviews}, :collection => {:add => :any, :autocomplete => :get, :list => :get} do |item|
    item.resources :labels
    item.resources :tips
  end
  map.resources :comments, :only => [:create], :collection => {:get_form => :get, :list => :get}
  map.tag_cloud "/tag_cloud/:item_id", :controller => 'labels', :action => 'tag_cloud'
  
  # map.trends "/items/:id/trends.csv", :controller => "items", :action => "trends"
  
  map.search "/search", :controller => "searches", :action => "show"
  map.search_auto "/search_autocomplete", :controller => "searches", :action => "autocomplete"
  map.search_api "/search_api", :controller => "searches", :action => "search_api"
  map.search_tags "/searches/tags", :controller => "searches", :action => "tags"
  map.google_search '/searches/image', :controller => 'searches', :action => 'image'
  
  # called via ajax, renders results partial
  map.search_results '/search/local', :controller => 'searches', :action => 'search_local'
  map.hyped_filter '/hyped_filter', :controller => 'items', :action => 'filter', :type => 'hyped'
  map.talked_filter '/talked_filter', :controller => 'items', :action => 'filter', :type => 'talked'
  map.rated_filter '/rated_filter', :controller => 'items', :action => 'filter', :type => 'rated'
  map.browse_filter '/browse_filter', :controller => 'items', :action => 'browse_filter'
  map.similar_items '/similar_items', :controller => 'items', :action => 'similar_items', :conditions=>{:method => :get}
  
  # called via ajax, renders hypes partial
  map.hypes_results '/partial/hypes/:id', :controller => 'users', :action => 'show_hypes'
  
  map.resources :friendships

  map.namespace :admin do |admin|
    admin.resource :dashboard, :controller => "dashboard"
    admin.resource :site_setting
    admin.resources :posts
    admin.resources :infos
    admin.resources :item_categories
    admin.resources :items do |item|
      item.resources :item_medias
    end
    admin.resources :users, :member => {:make_admin => :post, :remove_admin => :post, :activate => :post, :suspend => :put, :unsuspend => :put, :purge => :delete} 
    admin.resources :invites, :collection => {:reset => :post}, :member => {:approve => :get}
    admin.resources :profiles, :emails
    admin.resources :jobs, :collection => {:purge_queue => :get}
    # APP MARKER - Place app specific routes below this line
  end
  
  map.blog "/blog", :controller => "posts", :action => "index"
  map.admin "/admin", :controller => "admin/dashboard", :action => "show"
  
  map.signup "/signup", :controller => "users", :action => "new"
  map.signup_code "/signup/:invite", :controller => "users", :action => "new"
  map.login "/login", :controller => "sessions", :action => "new"
  map.beta_login "/beta_login", :controller => "sessions", :action => "beta_login"
  map.logout "/logout", :controller => "sessions", :action => "destroy"
  map.activate_user "/users/activate/:activation_code", :controller => "users", :action => "activate"

  # APP MARKER - Place app specific routes below this line
  map.homepage '/', :controller => "pages", :action => "index"
  map.landing '/landing', :controller => "pages", :action => "landing"
  map.beta_contact '/beta_contact', :controller => "pages", :action => "beta_contact"
  map.about '/about', :controller => "pages", :action => "about"
  map.reviews_list "/reviews/list", :controller => "reviews", :action => "list"
  map.already_hyped '/already_hyped/:item_id', :controller=>'items', :action=>'already_hyped'
  

  map.vanity_user_profile '/:id', :controller => 'users', :action => 'show', :id => /[a-zA-Z\-]+/, :vanity => 'yes'
  
  map.static_page "/:id", :controller => "pages", :action => "show"
  map.root :page
    
  map.page_error "page_error", :controller => "pages", :action => "page_error"
  map.page_not_found "page_not_found", :controller => "pages", :action => "page_not_found"    
  
  #path for video_selection 
  
  #path for vanity validation
  
  # iPhone API
  map.namespace :api do |api|
    api.resources :activities, :as => "events"
    api.resources :users, :collection => { :login => [:get, :post] }
    api.resources :items do |item|
      item.resources :reviews, :as => "hypes"
      item.resources :label_stats, :as => "pros", :requirements => {:pro => "1"}
      item.resources :label_stats, :as => "cons", :requirements => {:con => "1"}
      item.resources :favorites
      item.resources :item_medias, :as => "images"
      item.resources :comments do |comment|
        comment.resources :comments, :as => "replies"
      end
    end
  end
end
