require 'rails_helper'

RSpec.feature "MultiplePosts", type: :feature do
  scenario "てすと", js: true do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)

    visit root_path
    click_link "Log in"
    fill_in "Email", with: "user1@gmail.com"
    fill_in "Password", with: "foobar"
    click_button "Log in"

    click_link "Users"
    click_link user2.name
    click_button "Follow"
    debugger
    click_button "Unfollow"
    debugger

  end
end
