class LostPassword < ActionMailer::Base

  def send_reset_passwd(user,host)
    @subject    = "Reset Password Ruby on Br"
    @body       = {:host => host, :id => user.id,:name => user.display_name, :login_key => user.login_key, :password => user.password.reverse}
    @recipients = user.email
    @from       = "noreply@rubyonbr.org"
    @sent_on    = Time.now
    @headers    = {}
  end
end
