require File.dirname(__FILE__) + '/../test_helper'

class LostPasswordTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_send_reset_passwd
    @expected.subject = 'LostPassword#send_reset_passwd'
    @expected.body    = read_fixture('send_reset_passwd')
    @expected.date    = Time.now

    assert_equal @expected.encoded, LostPassword.create_send_reset_passwd(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/lost_password/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
