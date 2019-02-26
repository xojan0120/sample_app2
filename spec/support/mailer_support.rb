module MailerSupport
  def html_body(mail)
    mail.body.parts[1].body.raw_source
  end
  def text_body(mail)
    mail.parts.first.body.raw_source
  end
end

RSpec.configure do |config|
  config.include MailerSupport
end
