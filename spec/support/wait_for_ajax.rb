# wait_for_ajaxについて
# https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
module WaitForAjax
  def wait_for_ajax(wait_time = Capybara.default_max_wait_time)
    Timeout.timeout(wait_time) do
      loop until finished_all_ajax_requests?
    end
    yield if block_given?
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :system
end
