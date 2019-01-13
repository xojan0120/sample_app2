require 'rails_helper'

RSpec.feature "MultipleReply", type: :system do

  let!(:sender) { FactoryBot.create(:user, unique_name: "Mr_Sender") }
  let!(:receiver1) { FactoryBot.create(:user, unique_name: "Ms_Receiver1") }
  let!(:receiver2) { FactoryBot.create(:user, unique_name: "Ms_Receiver2") }
  let!(:other) { FactoryBot.create(:user) }

  scenario "ユーザは2人に返信ができる", js: true do
    msg = "@#{receiver1.unique_name} @#{receiver2.unique_name} こんにちわ"

    log_in_as sender
    visit_home
    post_content msg
    log_out

    log_in_as receiver1
    visit_home
    expect(page).to have_content msg
    log_out

    log_in_as receiver2
    visit_home
    expect(page).to have_content msg
    log_out

    log_in_as other
    visit_home
    expect(page).to_not have_content msg
  end

  #let(:user1) { FactoryBot.create(:user) }
  #let(:user2) { FactoryBot.create(:user) }

  #scenario "Capybara+Javascript設定動作確認", js: true do
  #  expect(user1.following?(user2)).to be_falsey

  #  visit root_path

  #  click_link "Log in"
  #  fill_in "Email", with: "user1@gmail.com"
  #  fill_in "Password", with: "foobar"
  #  click_button "Log in"

  #  click_link "Users"
  #  click_link user2.name
 
  #  expect {
  #    click_button "Follow"
  #    wait_for_ajax
  #  }.to change(user1.following, :count).by(1)

  #  expect {
  #    click_button "Unfollow"
  #    wait_for_ajax
  #  }.to change(user1.following, :count).by(-1)
  #end
end
