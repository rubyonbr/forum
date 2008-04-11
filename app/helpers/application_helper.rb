require 'md5'

module ApplicationHelper

  def submit_tag(value = "Salvar Alterações", options={} )
    or_option = options.delete(:or)
    return super + "<span class='button_or'>or " + or_option + "</span>" if or_option
    super
  end

  # Alterado para incluir um link diferente para o avatar
  def avatar_for(user, size=32)
    image_location = if user.avatar.nil? || user.avatar.empty?
        "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.md5(user.email)}&rating=PG&size=#{size}"
       else
        sanitize(user.avatar)
       end
    image_tag image_location, :size => "#{size}x#{size}", :class => 'photo'
  end

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('feed-icon', :size => '14x14', :alt => "Acompanhar #{title}"), url
  end

  def format_text(text)
  
    filtered_text = filter_code(text.to_s, "ruby", "ruby")
    filtered_text = filter_code(filtered_text, "code", "ruby")
    filtered_text = filter_code(filtered_text, "js", "javascript")
    filtered_text = filter_code(filtered_text, "css", "css")
    filtered_text = filter_code(filtered_text, "sql", "sql")
    
    clothed = RedCloth.new(filtered_text).to_html
    linked = auto_link(clothed)
    sanitize(linked)
  end
  
  def filter_code(text, tag, to)
    text.gsub(/(?:<pre>)?<#{tag}>(?:\r?\n)?(.*?)<\/#{tag}>(?:<\/pre>)?/smi) do
      "<notextile><textarea name='code' class='#{to}'>#{$1.to_s}</textarea></notextile>"
    end
  end
  

  def search_posts_title
    title = params[:q].blank? ? 'Posts recentes' : "procurando por '#{h params[:q]}'"
    #returning (query_title) do |title|
      title << " by #{h User.find(params[:user_id]).display_name}" if params[:user_id]
      title << " in #{h Forum.find(params[:forum_id]).name}"       if params[:forum_id]
    #end
    title
  end

  def search_posts_path
    options = params[:q].blank? ? {} : {:q => params[:q]}
    if params[:user_id]
      user_posts_url(options.reverse_merge(:user_id => params[:user_id]))
    elsif params[:forum_id]
      forum_posts_url(options.reverse_merge(:forum_id => params[:forum_id]))
    else
      all_posts_url(options)
    end
  end

  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round

    case distance_in_minutes
      when 0..1           then (distance_in_minutes==0) ? 'poucos segundos atrás' : '1 minuto atrás'
      when 2..59          then "#{distance_in_minutes} minutos atrás"
      when 60..90         then "1 hora atrás"
      when 90..1440       then "#{(distance_in_minutes.to_f / 60.0).round} horas atrás"
      when 1440..2160     then '1 dia atrás' # 1 day to 1.5 days
      when 2160..10080    then "#{(distance_in_minutes / 1440).round} dias atrás" # 1.5 days to 7 days
      when 10080..20160   then '1 semana atrás'
      else "#{(distance_in_minutes / 10080).round} semanas atrás"
      #else from_time.strftime("%d/%m/%y %H:%M")
    end
  end

end
