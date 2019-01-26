require 'rails_helper'

RSpec.feature "DirectMessage", type: :system do

  let!(:user1) { FactoryBot.create(:user, name: "ユーザ1", unique_name: "user1") }
  let!(:user2) { FactoryBot.create(:user, name: "ユーザ2", unique_name: "user2") }
  let!(:user3) { FactoryBot.create(:user, name: "ユーザ3", unique_name: "user3") }

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

  scenario "DMユーザ一覧画面テスト", js: true do
    # アプリケーションルートへアクセスする
    visit root_path

    # ユーザ1でログインする
    log_in_as(user1) do
      # DMリンクをクリックする
      click_link "DM"

      # DMユーザ一覧画面が表示されていることを検証する
      expect(page).to have_selector ".iziModal-header", text: "Direct Message Users"

      # DMユーザ一覧画面の過去にやりとりをしたことがあるユーザは表示されていないことを検証する
      expect(page).to_not have_selector "#modal", text: user1.name
      expect(page).to_not have_selector "#modal", text: user2.name
      expect(page).to_not have_selector "#modal", text: user3.name

      # Create DMリンクをクリックする
      click_link "Create DM"

      # DM宛先選択画面が表示されていることを検証する
      expect(page).to have_selector ".iziModal-header", text: "Create DM"

      # ✕アイコンをクリックする
      find(".iziModal-button-close").click
      wait_for_css_disappear(".iziModal-button-close", 5) do 
        # DMユーザ一覧画面が消えることを検証する
        expect(page).to_not have_content "Direct Message Users"
      end
    end
  end

  xscenario "DMユーザ覧画面テスト", js: true do
    # 送信者コメント
    log_in_as(sender) do
      visit_home
      post_content msg
    end

    # 受信者1のHomeに返信がある
    log_in_as(receiver1) do
      visit_home
      expect(page).to have_content msg, count: 1
    end

    # 受信者2のHomeに返信がある
    log_in_as(receiver2) do
      visit_home
      expect(page).to have_content msg, count: 1
    end

    # 受信者以外のHomeに返信はない
    log_in_as(other) do
      visit_home
      expect(page).to_not have_content msg
    end

    # 送信者が返信を削除する
    log_in_as(sender) do
      visit_home
      delete_first_content
      expect(page).to_not have_content msg
    end

    # 受信者1のHomeからも返信が削除されている
    log_in_as(receiver1) do
      visit_home
      expect(page).to_not have_content msg
    end

    # 受信者2のHomeからも返信が削除されている
    log_in_as(receiver2) do
      visit_home
      expect(page).to_not have_content msg
    end
  end
end
