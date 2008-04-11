class SessionsController < ApplicationController
  #  skip_before_filter :update_online
  def create
    self.current_user = User.find_and_valid(params[:login], params[:password])
    if logged_in?
      flash[:notice] = "Login com sucesso."
      cookies[:login_token]={ :value => "#{current_user.id};#{current_user.reset_login_key!}", :expires => Time.now.utc+1.year } if params[:remember_me]=="1"
      redirect_to home_path and return
    end
    flash.now[:notice] = "Login ou senha inválida, tente outra vez."
    render :action => 'new'
  end
  
  def destroy
    reset_session
    cookies.delete :login_token
    flash[:notice] = "Você se deslogou."
    redirect_to home_path
  end

  
  
  def lost_password
    render :partial => "lost_password"
    
  end
  def send_my_password
    ident=params[:identification].to_s
    
    @user=if ident.to_s =~ /@/
      User.find_by_email(ident)
    else
      User.find_by_login(ident)
    end
    
    LostPassword.deliver_send_reset_passwd(@user,request.host) if @user
    
    render :partial => "send_my_password"
    
  end

  def reset_my_password
    unless @user 
      @user=User.find_by_id_and_login_key_and_password(params[:id], params[:login_key], params[:password].reverse)
      @user.password=""
      session[:update_password]=@user
    end 
  end
  
  def update_password
    if session[:update_password].id == params[:id].to_i
      @user=User.find(params[:id])
      if @user.update_attributes(params[:user])
        flash[:notice]="Senha alterada com sucesso"
        #redirect_to :action => "index"
        
        redirect_to :controller => "login"
      else
        render :action => "reset_my_password"
        
      end
      
    else
      render :inline => "Operação não permitida #{session[:update_password].id.class} != #{params[:id].class}"
    end
    
    
  end
  
end
