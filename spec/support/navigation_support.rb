module NavigationSupport
  def visit_home
    click_link "Home"
  end
end

RSpec.configure do |config|
  config.include NavigationSupport
end
