module NavigationSupport
  def visit_home
    click_link "Home"
  end
  def visit_settings
    click_link "Account"
    click_link "Settings"
  end
  def visit_users
    click_link "Users"
  end
end

RSpec.configure do |config|
  config.include NavigationSupport
end
