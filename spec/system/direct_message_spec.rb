require 'rails_helper'

RSpec.feature "DirectMessage", type: :system do

  let!(:me)               { FactoryBot.create(:user, name: "ユーザ1", unique_name: "John_smith") }
  let!(:following_user)   { FactoryBot.create(:user, name: "ユーザ2", unique_name: "Jane_smith") }
  let!(:unfollowing_user) { FactoryBot.create(:user, name: "ユーザ3", unique_name: "Agent_smith") }

  let(:users_index_title) { "Direct Message Users" }
  let(:to_select_title)   { "Create DM" }

  before do
    me.follow(following_user)
  end

  def expect_to_have_title(title)
    expect(page).to have_selector ".iziModal-header-title", text: title
  end

  def expect_to_not_have_title(title)
    expect(page).to_not have_selector ".iziModal-header-title", text: title
  end

  def close_modal
    find(".iziModal-button-close").click
    wait_for_css_disappear(".iziModal-button-close", 5)
  end

  scenario "DMユーザ一覧画面テスト", js: true do
    visit root_path

    log_in_as(me) do
      # DMユーザ一覧画面が表示される
      click_link "DM"
      expect_to_have_title(users_index_title)

      # DMユーザ一覧画面の過去にやりとりをしたことがあるユーザは表示されていない
      expect(page).to_not have_selector "#modal", text: me.name
      expect(page).to_not have_selector "#modal", text: following_user.name
      expect(page).to_not have_selector "#modal", text: unfollowing_user.name

      # DM宛先選択画面が表示されている
      click_link "Create DM"
      expect_to_have_title(to_select_title)

      # 閉じるボタンでDMユーザ一覧画面が閉じる
      close_modal
      expect_to_not_have_title(users_index_title)
    end
  end

  scenario "DM宛先選択画面1(戻るリンクでDMユーザ一覧画面に戻る)", js: true do
    visit root_path
    log_in_as(me) do
      # 戻るリンクでDMユーザ一覧画面に戻る
      click_link "DM"
      expect_to_have_title(users_index_title)
      click_link "Create DM"
      expect_to_have_title(to_select_title)
      click_link "←"
      expect_to_have_title(users_index_title)

      # 閉じるボタンでDM宛先選択画面が閉じる
      close_modal
      expect_to_not_have_title(to_select_title)
    end
  end

  scenario "DM宛先選択画面2(ユーザ名または一意ユーザ名で検索ができる)", js: true do
    visit root_path
    log_in_as(me) do
      click_link "DM"
      click_link "Create DM"

      # -------------------------------------------
      # フォローユーザについて
      # -------------------------------------------
      # ユーザ名で検索ができる
      fill_in "to_search_form", with: following_user.name
      expect(page).to have_selector "#result", text: following_user.name

      # 検索ボックスの内容を消去し、検索結果が消える
      # ※中身が空の要素を探す方法不明
      #fill_in "to_search_form", with: ""

      # 一意ユーザ名で検索
      fill_in "to_search_form", with: following_user.unique_name
      expect(page).to have_selector "#result", text: following_user.unique_name

      # -------------------------------------------
      # フォローしていないユーザについて
      # -------------------------------------------
      # ユーザ名で検索しても出さない
      fill_in "to_search_form", with: unfollowing_user.name
      expect(page).to_not have_selector "#result", text: unfollowing_user.name

      # 一意ユーザ名で検索しても出さない
      fill_in "to_search_form", with: unfollowing_user.unique_name
      expect(page).to_not have_selector "#result", text: unfollowing_user.unique_name

      # 閉じるボタンでDM宛先選択画面が閉じる
      close_modal
      expect_to_not_have_title(to_select_title)
    end
  end

  fscenario "DM一覧画面テスト(ユーザ1→ユーザ2へのメッセージ送信)", js: true do
    visit root_path
    log_in_as(me) do
      click_link "DM"
      click_link "Create DM"

      # DM宛先選択画面から検索してユーザ2を選択し、DM一覧画面が表示される
      fill_in "to_search_form", with: following_user.name
      expect(page).to have_selector "#result", text: following_user.name
      find(%Q( [data-user-id="#{following_user.id}"] )).click
      expect_to_have_title(following_user.name)

      # 戻るリンクでDM宛先選択画面に戻る
      click_link "←"
      expect_to_have_title(to_select_title)

      # 再びDM宛先選択画面からユーザ2を検索しDM一覧画面を表示する
      fill_in "to_search_form", with: following_user.name
      expect(page).to have_selector "#result", text: following_user.name
      find(%Q( [data-user-id="#{following_user.id}"] )).click

      # メッセージを入力
      msg = "こんにちわ"
      fill_in "direct_message[content]", with: msg

      # 画像をセット
      expect(page).to have_css(".glyphicon-picture")
      image_path = 'spec/factories/images/rails.png'
      image_full_path = Rails.root.join(image_path)
      attach_file('direct_message[picture]', image_full_path)

      # 送信後、メッセージと画像が表示される
      click_button "Send"
      expect(page).to have_selector "#messages", text: msg
      expect(find('img')['src']).to have_content(File.basename(image_path))

      close_modal
      expect_to_not_have_title(following_user.name)
    end
  end

end
