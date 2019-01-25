module WaitForCss
  # cssが表示されるまで待つ
  def wait_for_css_appear(selector, wait_time = Capybara.default_max_wait_time)
    Timeout.timeout(wait_time) do
      loop until has_css?(selector)
    end
    yield
  end

  # cssが表示されなくなるまで待つ
  def wait_for_css_disappear(selector, wait_time = Capybara.default_max_wait_time)
    Timeout.timeout(wait_time) do
      loop until has_no_css?(selector)
    end
    yield
  end
end

RSpec.configure do |config|
  config.include WaitForCss, type: :system
end
