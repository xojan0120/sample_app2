module LoginSupport
  #def log_in_as(user, password = "foobar")
  #  click_link "Log in"
  #  fill_in "Email", with: user.email
  #  fill_in "Password", with: password
  #  click_button "Log in"
  #end

  def log_in_as(user, password = "foobar", log_out_user: true)
    click_link "Log in"
    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"

    yield

    log_out if log_out_user
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
