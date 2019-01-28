require 'rails_helper'

RSpec.feature "DirectMessage", type: :system do

  let!(:user1) { FactoryBot.create(:user, name: "ユーザ1", unique_name: "user1") }
  let!(:user2) { FactoryBot.create(:user, name: "ユーザ2", unique_name: "user2") }
  let!(:user3) { FactoryBot.create(:user, name: "ユーザ3", unique_name: "user3") }

  let(:users_index_title)     { "Direct Message Users" }
  let(:to_search_title) { "Create DM" }

  before do
    user1.follow(user2)
  end

  #fscenario "test", js: true do
  #  visit root_path

  #  log_in_as(user1) do
  #    click_link "DM"
  #    expect(page).to have_content "Direct Message Users"
  #    find(".iziModal-button-close").click
  #    wait_for_css_disappear(".iziModal-button-close", 5) do 
  #      expect(page).to_not have_content "Direct Message Users"
  #    end
  #  end
  #end
  
  #fscenario "test", js: true do
  #  visit root_path
  #  log_in_as(user1) do
  #    click_link "DM"
  #    expect(page).to have_selector "#modal", text: "Find me in app"
  #  end
  #end

  def expect_to_have_title(title)
    expect(page).to have_selector ".iziModal-header-title", text: title
  end
  def expect_to_not_have_title(title)
    expect(page).to_not have_selector ".iziModal-header-title", text: title
  end

  scenario "DMユーザ一覧画面テスト", js: true do
    visit root_path

    log_in_as(user1) do
      # DMユーザ一覧画面が表示される
      click_link "DM"
      expect_to_have_title(users_index_title)

      # DMユーザ一覧画面の過去にやりとりをしたことがあるユーザは表示されていない
      expect(page).to_not have_selector "#modal", text: user1.name
      expect(page).to_not have_selector "#modal", text: user2.name
      expect(page).to_not have_selector "#modal", text: user3.name

      # DM宛先選択画面が表示されている
      click_link "Create DM"
      expect_to_have_title(to_search_title)

      # 閉じるボタンでDMユーザ一覧画面が閉じる
      find(".iziModal-button-close").click
      wait_for_css_disappear(".iziModal-button-close", 5) do 
        expect_to_not_have_title(users_index_title)
      end
    end
  end

  fscenario "DM宛先選択画面テスト", js: true do
    visit root_path
    
    log_in_as(user1) do
      click_link "DM"

      # 戻るリンクでDMユーザ一覧画面に戻る
      click_link "Create DM"
      click_link "←"
      expect_to_have_title(users_index_title)

      click_link "Create DM"
      expect_to_have_title(to_search_title)

      ## -----------------------------------
      ## 以下フォローしているユーザについて
      ## -----------------------------------
      ## ユーザ名で検索ができる
      sleep 5
      fill_in "user_To", with: user2.name  # →ここの入力がうまくいかない。
      #expect(page).to have_selector ".result", text: user2.name

      ## 一意ユーザ名で検索ができる
      #fill_in "name", with: user2.unique_name
      #expect(page).to have_selector ".result", text: user2.unique_name
      ## -----------------------------------
      ## ここまで
      ## -----------------------------------

      ## -----------------------------------
      ## 以下フォローしていないユーザについて
      ## -----------------------------------
      ## ユーザ名で検索しても出さない
      #fill_in "name", with: user3.name
      #expect(page).to_not have_selector ".result", text: user3.name

      ## 一意ユーザ名で検索しても出さない
      #fill_in "name", with: user3.unique_name
      #expect(page).to have_selector ".result", text: user3.unique_name
      ## -----------------------------------
      ## ここまで
      ## -----------------------------------
      #
      ## 閉じるボタンでDM宛先選択画面が閉じる
      #find(".iziModal-button-close").click
      #wait_for_css_disappear(".iziModal-button-close", 5) do 
      #  expect_to_not_have_title(to_search_title)
      #end
    end
  end

end
