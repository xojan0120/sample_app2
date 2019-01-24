require 'rails_helper'

RSpec.feature "DirectMessage", type: :system do

  let!(:user1) { FactoryBot.create(:user, name: "ユーザ１", unique_name: "user1") }
  let!(:user2) { FactoryBot.create(:user, name: "ユーザ２", unique_name: "user2") }
  let!(:user3) { FactoryBot.create(:user, name: "ユーザ３", unique_name: "user3") }

  before do
    user1.follow(user2)
  end

  scenario "ダイレクトメッセージ機能システムテスト", js: true do

    visit root_path

    log_in_as(user1) do
      click_link "DM"

      # DMユーザ一覧画面が表示されている
      expect(page).to have_content "Direct Message Users"

      # DMユーザ一覧画面の過去にやりとりをしたことがあるユーザは表示されていないことを検証する
      expect(page).to_not have_content user1.name
      expect(page).to_not have_content user2.name
      expect(page).to_not have_content user3.name

      # DMユーザ一覧画面を閉じる
      click_link "✕"
      
      # DMユーザ一覧画面が消去されている
      expect(page).to_not have_content "Direct Message Users"
    end

=begin
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
=end
  end
end
