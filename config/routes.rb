Rails.application.routes.draw do
  # TODO: use only in archive sidebar. See how made other system
  match ':year/:month', :to => 'articles#index', :year => /\d{4}/, :month => /\d{1,2}/, :as => 'articles_by_month', :format => false
  match ':year/:month/page/:page', :to => 'articles#index', :year => /\d{4}/, :month => /\d{1,2}/, :as => 'articles_by_month_page', :format => false
  match ':year', :to => 'articles#index', :year => /\d{4}/, :as => 'articles_by_year', :format => false
  match ':year/page/:page', :to => 'articles#index', :year => /\d{4}/, :as => 'articles_by_year_page', :format => false


  match 'articles.:format', :to => 'articles#index', :constraints => {:format => 'rss'}, :as => 'rss'
  match 'articles.:format', :to => 'articles#index', :constraints => {:format => 'atom'}, :as => 'atom'

  scope :controller => 'xml', :path => 'xml', :as => 'xml' do
    match 'articlerss/:id/feed.xml', :action => 'articlerss', :format => false
    match 'commentrss/feed.xml', :action => 'commentrss', :format => false
    match 'trackbackrss/feed.xml', :action => 'trackbackrss', :format => false
  end

  match 'xml/:format', :to => 'xml#feed', :type => 'feed', :constraints => {:format => 'rss'}, :as => 'xml'
  match 'sitemap.xml', :to => 'xml#feed', :format => 'googlesitemap', :type => 'sitemap', :as => 'xml'

  scope :controller => 'xml', :path => 'xml', :as => 'xml' do
    scope :action => 'feed' do
      match ':format/feed.xml', :type => 'feed'
      match ':format/:type/:id/feed.xml'
      match ':format/:type/feed.xml'
    end
  end

  match 'xml/rsd', :to => 'xml#rsd', :format => false
  match 'xml/feed', :to => 'xml#feed'

  # CommentsController
  resources :comments, :as => 'admin_comments' do
    collection do
      match :preview
    end
  end

  resources :trackbacks

  # I thinks it's useless. More investigating
  post "trackbacks/:id/:day/:month/:year", :to => 'trackbacks#create', :format => false

  # ArticlesController
  match '/live_search/', :to => 'articles#live_search', :as => :live_search_articles, :format => false
  match '/search/:q(.:format)/page/:page', :to => 'articles#search', :as => 'search'
  match '/search(/:q(.:format))', :to => 'articles#search', :as => 'search'
  match '/search/', :to => 'articles#search', :as => 'search_base', :format => false
  match '/archives/', :to => 'articles#archives', :format => false
  match '/page/:page', :to => 'articles#index', :page => /\d+/, :format => false
  get '/pages/*name', :to => 'articles#view_page', :format => false
  match 'previews(/:id)', :to => 'articles#preview', :format => false
  match 'previews_pages(/:id)', :to => 'articles#preview_page', :format => false
  match 'check_password', :to => 'articles#check_password', :format => false
  match 'articles/markup_help/:id', :to => 'articles#markup_help', :format => false
  match 'articles/tag', :to => 'articles#tag', :format => false

  # SetupController
  match '/setup', :to => 'setup#index', :format => false

  # TagsController (imitate inflected_resource)
  resources :tags, :except => [:show, :update, :destroy, :edit]
  resources :tags, :path => 'tag', :only => [:show, :edit, :update, :destroy]
  match '/tag/:id/page/:page', :to => 'tags#show', :format => false
  match '/tags/page/:page', :to => 'tags#index', :format => false

  resources :author, only: :show

  # ThemesController
  scope :controller => 'theme', :filename => /.*/ do
    get 'stylesheets/theme/:filename', :action => 'stylesheets', :format => false
    get 'javascripts/theme/:filename', :action => 'javascript', :format => false
    get 'images/theme/:filename', :action => 'images', :format => false
  end

  # For the tests
  get 'theme/static_view_test', :format => false

  # For the statuses
  match '/notes', :to => 'notes#index', :format => false
  match '/notes/page/:page', :to => 'notes#index', :format => false
  get '/note/:permalink', :to => 'notes#show', :format => false

  get '/humans', to: 'text#humans', format: 'txt'
  get '/robots', to: 'text#robots', format: 'txt'

  namespace :admin do
    get '/', to: 'dashboard#index', as: 'dashboard'
    resources :sidebar, only: [:index, :update, :destroy] do
      collection do
        put :sortable
      end
    end

    resources :notes, except: [:new]

    get 'cache', to: 'cache#show'
    delete 'cache', to: 'cache#destroy'
  end

  # Work around the Bad URI bug
  %w{ accounts files sidebar }.each do |i|
    match "#{i}", :to => "#{i}#index", :format => false
    match "#{i}(/:action)", :to => i, :format => false
    match "#{i}(/:action(/:id))", :to => i, :id => nil, :format => false
  end

  # Admin/XController
  %w{content comments profiles general pages feedback resources sidebar textfilters themes trackbacks users settings tags redirects seo post_types}.each do |i|
    match "/admin/#{i}", to: "admin/#{i}#index", format: false
    match "/admin/#{i}(/:action(/:id))", to: "admin/#{i}", action: nil, id: nil, format: false
  end

  root :to  => 'articles#index', :format => false

  get '*from', :to => 'articles#redirect', :format => false
end
