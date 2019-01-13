require 'rails_helper'

RSpec.feature "SingleReply", type: :system do
  let!(:sender) { FactoryBot.create(:user, unique_name: "Mr_Sender") }
  let!(:receiver) { FactoryBot.create(:user, unique_name: "Ms_Receiver") }
  let!(:other) { FactoryBot.create(:user) }

  scenario "ユーザは1人に返信ができる", js: true do
    msg = "@#{receiver.unique_name} こんにちわ"

    log_in_as sender
    visit_home
    post_content msg
    log_out

    log_in_as receiver
    visit_home
    expect(page).to have_content msg
    log_out

    log_in_as other
    visit_home
    expect(page).to_not have_content msg
  end
end
