require 'rails_helper'

RSpec.feature "ReplyPost", type: :system do
  let!(:sender) { FactoryBot.create(:user, unique_name: "Mr_Sender") }
  let!(:receiver) { FactoryBot.create(:user, unique_name: "Ms_Receiver") }
  let!(:other) { FactoryBot.create(:user) }

  scenario "ユーザは１人に返信ができる", js: true do
    test_msg = "@#{receiver.unique_name} こんにちわ"

    log_in_as sender
    click_link "Home"
    fill_in "micropost_content", with: test_msg
    click_button "Post"
    log_out

    log_in_as receiver
    click_link "Home"
    expect(page).to have_content test_msg
    log_out

    log_in_as other
    click_link "Home"
    expect(page).to_not have_content test_msg
  end
end
