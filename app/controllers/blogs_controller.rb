class BlogsController < ApplicationController

  before_filter :admin_only, :except => :blogosphere
  before_filter :expire_index, :only => :blogosphere

  def admin_only
    #unless current_user && current_user != 0 && current_user.admin?
    #  redirect_to :forums_path
    #  false
    #end
  end

  def expire_index
    if last_cache < 30.minutes.ago
      reset_cache
    end
  end

  def blogosphere
    respond_to do |wants|

      wants.html do
        find_posts unless read_fragment(:action => 'blogosphere', :part => 'posts')
      end

      wants.rss do
        find_posts unless read_fragment(:action => 'blogosphere', :format => 'rss')
        @headers["Content-Type"] = "text/xml; charset=utf-8"
        render :partial => 'blogosphere_rss'
      end
    end
  end

  def reset_cache
    reset
    redirect_to blogs_path
  end

  def index
    @blogs = Blog.find(:all, :order => 'author')
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(params[:blog])
    @blog.save!
    reset_cache
    redirect_to blogs_path
  end

  def edit
    @blog = Blog.find(params[:id])
  end

  def update
    @blog = Blog.find(params[:id])
    @blog.attributes = params[:blog]
    @blog.save!
    reset_cache
    redirect_to blogs_path
  end

  def destroy
    blog = Blog.find(params[:id])
    blog.destroy if blog
    redirect_to blogs_path
  end

  def reset
    reset_cache
    redirect_to blogs_path
  end

  def last_cache
    config = Configuration.find_by_name('blogs_last_cache')
    config ? Time.parse(config.value) : 1.month.ago # 1 month ago = expired cache
  end

protected

  def set_cache_time()
    config = Configuration.find_by_name('blogs_last_cache')
    config = Configuration.new(:name => 'blogs_last_cache') unless config;
    config.value = Time.now.to_s
    config.save
  end

  def reset_cache
    expire_fragment :action => 'blogosphere', :part => 'blogs'
    expire_fragment :action => 'blogosphere', :part => 'posts'
    expire_fragment :action => 'blogosphere', :format => 'rss'
  end

  def find_posts
    @posts = Blog.find_all_posts
    @blogs = @posts.collect {|it| it.blog}.uniq
    set_cache_time
  end
end
