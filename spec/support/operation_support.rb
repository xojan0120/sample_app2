module OperationSupport
  def post_content(msg)
    fill_in "micropost_content", with: msg
    click_button "Post"
  end
end

RSpec.configure do |config|
  config.include OperationSupport
end
