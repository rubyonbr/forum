require File.dirname(__FILE__) + '/../test_helper'

class IsoToUtfTest < Test::Unit::TestCase

  def test_convert
    open(File.dirname(__FILE__)+'/iso8859-1.txt') do |file|
      text = file.read
      puts '================'
      puts text.unpack('C*').pack('U*')
    end
  end
end