module LoginSupport
  def log_in_as(user)
    visit root_path
    click_link "Log in"
    fill_in "Email", with: user.email
    fill_in "Password", with: "foobar"
    click_button "Log in"
  end

  # use javascript
  def log_out
    click_link "Account"
    click_link "Log out"
  end
end

RSpec.configure do |config|
  config.include LoginSupport
end
