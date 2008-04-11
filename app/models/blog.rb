class Blog < ActiveRecord::Base

  attr_accessor :channel
  attr_accessor :items

  def self.find_all_posts(limit = 10)
    blogs = Blog.find(:all)
    blogs.each(&:recover)

    posts = []
    blogs.each do |blog|
      posts.push(*blog.posts)
    end
    posts.sort!{|a,b| b.date <=> a.date}

    posts[0, limit]
  end

  def recover
    begin
      open(self.rss) do |http|
        response = http.read
        response = response.iso88591_to_utf8 if response.split(/\r?\n/)[0] =~ /ISO-8859-1/i
        rss = SimpleRSS.parse(response)
        self.channel= rss.channel
        self.items = rss.items
      end
    rescue
      # If we can't get an RSS, just ignore it. We can survive without it :)
    end
  end

  def posts
    posts = []
    (self.items || []).each do |item|
      post = OpenStruct.new
      post.blog = self
      post.avatar = self.avatar
      post.channel_title = self.channel.title
      post.channel_link = self.url
      post.blog_link = self.url
      post.title = item.title
      post.author = self.author
      
      # Getting the part that really interest, the rss text.
      # After we get it, we do some cleanup.
      text = item.content_encoded || item.content || CGI::unescapeHTML(item.description)
      post.description = Blog.fix_links(text, post.blog_link)

      # Some blogs has the text "escaped", we try to detect that and replace
      # the &lt; and &gt; to their right values. This is not the best thing in
      # the word, but it's the best we could do in few minutes.
      if post.description =~ /(&lt;p&gt;|&lt;br&gt;|&lt;br\s*\/&gt;)/
        post.description.gsub!('&lt;', '<').gsub!('&gt;', '>')
      end

      # Switching <code> tags to <pre> tags
      post.description.gsub!(/<(\/)?code>/, '<\1pre>')

      post.link = item.link
      post.comment_link = self.comment_expression.gsub(/:link/, post.link)
      post.date = item.published || item.modified || item.pubDate
      post.instance_eval do
        def date_as_string
          if self.date.strftime('%H:%M') == '00:00'
            self.date.strftime('%Y-%m-%d')
          else
            self.date.strftime('%Y-%m-%d %H:%M')
          end
        end
      end
      
      # If "restricted" is set to true, show the post only if the title or description
      # contains one of these words
      filter = /(?:ruby|rails|rubyonbr|radrails)/im
      posts << post if !self.restricted || post.title =~ filter || post.description =~ filter
    end
    posts
  end

  def self.fix_links(description, base_link)
    description.gsub(/((?:src|href)\s*=\s*['"]?(?!https?:\/\/))(\/?)([^'"]+)(['" ]?)/) {|it| $1 + base_link + '/' + $3 + $4}
  end
end
