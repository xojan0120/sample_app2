RSpec.configure do |config|
  config.before(:each, type: :system) do
    # rack_testだとtake_screenshotがなぜか使えなかったりする
    # driven_by :rack_test
    driven_by :selenium_chrome_headless
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end
end
#Capybara.javascript_driver = :selenium_chrome_headless
