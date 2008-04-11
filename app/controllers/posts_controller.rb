class PostsController < ApplicationController
  before_filter :find_post,      :except => [:index, :create]
  before_filter :login_required, :except => [:index]
  
  def index
    conditions = []; params[:page] = 1 if params[:format] == 'rss'
    
    [:user_id, :forum_id].each do |attr| 
          conditions << Post.send(:sanitize_sql, ["posts.#{attr} = ?", params[attr]]) if params[attr] 
    end
    #nova pesquisa usando regexp do postgresql,o ~* insensitive
    unless params[:q].blank?
      words=params[:q].split(/\s/)
      conds=(["posts.body ~* ?"] * words.size).join(" and ")
      conditions << Post.send(:sanitize_sql, [ conds,*words]) 
    end
    @post_pages, @posts = paginate(:posts, :per_page => 25, :select => 'posts.*, topics.title as topic_title', :joins => 'inner join topics on posts.topic_id = topics.id',
    :conditions => conditions.any? ? conditions.collect { |c| "(#{c})" }.join(' AND ') : nil, :order => 'posts.created_at desc, posts.id desc')
    
    respond_to do |format|
      format.html
      format.rss { render :action => 'index.rxml', :layout => false }
    end
  end
  
  def create
    @topic = Topic.find_by_id_and_forum_id(params[:topic_id],params[:forum_id], :include => :forum)
    @forum = @topic.forum
    @post  = @topic.posts.build(params[:post])
    @post.user = current_user
    @post.save!
    #last_posts(:reload => @forum.id)
    redirect_to topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1')
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'Por favor, poste alguma coisa...'
    redirect_to topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => 'reply-form', :page => params[:page] || '1')
  end
  
  def update
    @post.attributes = params[:post]
    if @post.save
      redirect_to topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1')
    else
      render(:action => "edit")
    end
  end
  
  def destroy
    find_forum
    find_topic
    @post.destroy
    flash[:notice] = "Post de '#{CGI::escapeHTML @post.topic.title}' foi apagado."
    if @topic.posts && @topic.posts.count > 0
      redirect_to topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :page => params[:page]) 
    else
      @topic.destroy
      redirect_to forum_path(@forum)
    end
  end
  
  protected
  def authorized?
    action_name == 'create' || @post.editable_by?(current_user)
  end
  
  def find_post
    @post = Post.find_by_id_and_topic_id_and_forum_id(params[:id], params[:topic_id], params[:forum_id]) || raise(ActiveRecord::RecordNotFound)
  end
  
  def find_forum
    @forum = Forum.find(params[:forum_id])
  end
  
  def find_topic
    @topic = @forum.topics.find(params[:topic_id])
  end
  
end
