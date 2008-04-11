class AggregatorController < ApplicationController
  
  def index
  end
  
  def show
    open('http://logbr.reflectivesurface.com/feed/rss/') do |http|
    #open('http://eustaquiorangel.com/feeds/rss') do |http|
    #open('http://www.balanceonrails.com.br/xml/rss/feed.xml') do |http|
      response = http.read
      rss = RSS::Parser.parse(response, false)
      @channel= rss.channel
      @items = rss.items    
    end
  end
end
