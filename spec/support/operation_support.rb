module OperationSupport
  def post_content(msg)
    fill_in "micropost_content", with: msg
    click_button "Post"
  end

  def delete_first_content
    accept_alert do
      click_link "delete", match: :first
    end
  end

  def click_follow(time = 1)
    click_button "Follow"
    sleep time
  end

  def click_unfollow(time = 1)
    click_button "Unfollow"
    sleep time
  end
end

RSpec.configure do |config|
  config.include OperationSupport
end
