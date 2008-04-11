class TopicsController < ApplicationController
  before_filter :find_forum, :except => [:index, :preview]
  before_filter :find_topic, :except => [:index, :new, :create, :preview]
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  # see notes in application.rb on how this works
  before_filter :update_last_seen_at, :only => :show

  def index
    redirect_to forum_path(params[:forum_id])
  end

  def new
    @topic = Topic.new
  end
  
  def show
    # authors of topics don't get counted towards total hits
    @topic.hit! unless logged_in? and @topic.user == current_user
    # keep track of when we last viewed this topic for activity indicators
    (session[:topics] ||= {})[@topic.id] = Time.now.utc if logged_in?

    respond_to do |format|
      format.html do
        Post.with_scope :find => { :conditions => ['topic_id = ?', params[:id]] } do
          @post_pages, @posts = paginate(:posts, :per_page => 25, :order => 'created_at')
        end
        @post  = Post.new
      end
      format.rss do
        @posts = @topic.posts.find(:all, :order => 'created_at desc', :limit => 25)
        render :action => 'show.rxml', :layout => false
      end
    end
  end
  
  def create
    # this is icky - move the topic/first post workings into the topic model?
    begin
      Topic.transaction do
        @topic = @forum.topics.build(params[:topic])
        assign_protected
        @topic.save!
        @post = @topic.posts.build(params[:topic])
        @post.user = current_user
        @post.save!
      end
      redirect_to topic_path(@forum, @topic)
    rescue
      if @post && @post.errors
        @post.errors.each_full do |error|
          @topic.errors.add(error)
        end
      end
      render(:action => 'new')
    end
  end
  
  def update
    @topic.attributes = params[:topic]
    assign_protected
    @topic.save!
    redirect_to topic_path(@topic.forum, @topic)
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = "Tópico '#{CGI::escapeHTML @topic.title}' foi apagado."
    redirect_to forum_path(@forum)
  end
  
  def preview
    hash = params[:post] || params[:topic]
    @body = hash[:body]
    render :partial => "preview"
  end
  
  protected
    def assign_protected
      @topic.user     = current_user if @topic.new_record?
      return unless admin?
      @topic.sticky   = params[:topic][:sticky] 
      @topic.forum_id = params[:topic][:forum_id] if params[:topic][:forum_id]
    end
  
    def find_forum
      @forum = Forum.find(params[:forum_id])
    end
    
    def find_topic
      @topic = @forum.topics.find(params[:id])
    end
    
    def authorized?
      %w(new create).include?(action_name) || @topic.editable_by?(current_user)
    end
end
