class UsersController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy, :admin]
  before_filter :find_user,      :only => [:edit, :update, :destroy, :admin]

  def index
    @user_pages, @users = paginate(:users, :per_page => 25, :order => "display_name", :conditions => (params[:q] && ['LOWER(display_name) LIKE ?', "%#{params[:q]}%"]))
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.login = params[:user][:login]
    @user.save!
    flash[:notice]="Você criou uma conta, agora você precisa logar pela primeira vez."
    redirect_to login_path
  end
  
  def update
    @user.attributes = params[:user]
    # temp fix to let people with dumb usernames change them
    @user.login = params[:user][:login] if not @user.valid? and @user.errors.on(:login)
    @user.save!
    redirect_to user_path(@user)
  end

  def admin
    @user.update_attributes(params[:user])
    @user.admin = params[:user][:admin] == '1'
    @user.save
    unless params[:moderator].blank? || params[:moderator] == '-'
      forum = Forum.find(params[:moderator])
      @user.moderatorships.create(:forum_id => forum.id)
    end
    redirect_to user_path(@user)
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  protected
    def authorized?
      admin? || (!%w(destroy admin).include?(action_name) && (params[:id].nil? || params[:id] == current_user.id.to_s))
    end
    
    def find_user
      @user = params[:id] ? User.find_by_id(params[:id]) : current_user
    end
end
