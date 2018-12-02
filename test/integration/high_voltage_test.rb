require 'test_helper'

class HighVoltageTest < ActionDispatch::IntegrationTest
  test "high voltage test" do
    get page_path('test')
    assert_response :success
  end
end
