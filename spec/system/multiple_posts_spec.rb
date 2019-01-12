require 'rails_helper'

RSpec.feature "MultiplePosts", type: :system do
  scenario "Capybara+Javascript設定動作確認", js: true do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    expect(user1.following?(user2)).to be_falsey

    visit root_path

    click_link "Log in"
    fill_in "Email", with: "user1@gmail.com"
    fill_in "Password", with: "foobar"
    click_button "Log in"

    debugger

    click_link "Users"
    click_link user2.name
 
    expect {
      click_button "Follow"
      wait_for_ajax
    }.to change(user1.following, :count).by(1)

    expect {
      click_button "Unfollow"
      wait_for_ajax
    }.to change(user1.following, :count).by(-1)
  end

  #describe "describe" do
  #  context "context" do
  #    it "it" do
  #    end
  #  end
  #end
end
