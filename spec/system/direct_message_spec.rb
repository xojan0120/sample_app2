require 'rails_helper'

RSpec.feature "DirectMessage", type: :system do

  let!(:me)               { FactoryBot.create(:user, name: "ユーザ1", unique_name: "John_smith") }
  let!(:following_user)   { FactoryBot.create(:user, name: "ユーザ2", unique_name: "Jane_smith") }
  let!(:unfollowing_user) { FactoryBot.create(:user, name: "ユーザ3", unique_name: "Agent_smith") }

  let(:users_index_title) { "Direct Message Users" }
  let(:to_search_title)   { "Create DM" }

  before do
    me.follow(following_user)
  end

  #fscenario "test", js: true do
  #  visit root_path

  #  log_in_as(me) do
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
  #  log_in_as(me) do
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
      expect_to_have_title(to_search_title)

      # 閉じるボタンでDMユーザ一覧画面が閉じる
      find(".iziModal-button-close").click
      wait_for_css_disappear(".iziModal-button-close", 5) do 
        expect_to_not_have_title(users_index_title)
      end
    end
  end

  xscenario "testest", js: true do
    visit root_path
    log_in_as(me) do
      click_link "Home"
      debugger
    end
  end

  scenario "DM宛先選択画面1(戻るリンクでDMユーザ一覧画面に戻る)", js: true do
    visit root_path
    log_in_as(me) do
      # 戻るリンクでDMユーザ一覧画面に戻る
      click_link "DM"
      expect_to_have_title(users_index_title)
      click_link "Create DM"
      expect_to_have_title(to_search_title)
      click_link "←"
      expect_to_have_title(users_index_title)

      # 閉じるボタンでDM宛先選択画面が閉じる
      find(".iziModal-button-close").click
      wait_for_css_disappear(".iziModal-button-close", 5) do 
        expect_to_not_have_title(to_search_title)
      end
    end
  end

  scenario "DM宛先選択画面2(ユーザ名または一意ユーザ名で検索ができる)", js: true do
    visit root_path
    log_in_as(me) do
      # 戻るリンクでDMユーザ一覧画面に戻る
      click_link "DM"
      click_link "Create DM"

      # -------------------------------------------
      # フォローユーザについて
      # -------------------------------------------
      # ユーザ名で検索ができる
      fill_in "direct_message_to", with: following_user.name
      click_button "検索"
      expect(page).to have_selector ".result", text: following_user.name

      # 一意ユーザ名で検索
      fill_in "direct_message_to", with: following_user.unique_name
      click_button "検索"
      expect(page).to have_selector ".result", text: following_user.unique_name

      # -------------------------------------------
      # フォローしていないユーザについて
      # -------------------------------------------
      # ユーザ名で検索しても出さない
      fill_in "direct_message_to", with: unfollowing_user.name
      click_button "検索"
      expect(page).to_not have_selector ".result", text: unfollowing_user.name

      # 一意ユーザ名で検索しても出さない
      fill_in "direct_message_to", with: unfollowing_user.unique_name
      click_button "検索"
      expect(page).to_not have_selector ".result", text: unfollowing_user.unique_name

      # 閉じるボタンでDM宛先選択画面が閉じる
      find(".iziModal-button-close").click
      wait_for_css_disappear(".iziModal-button-close", 5) do 
        expect_to_not_have_title(to_search_title)
      end
    end
  end

  fscenario "test", js: true do
    visit root_path
    
    log_in_as(me) do
      click_link "DM"
      expect_to_have_title(users_index_title)
      click_link "Create DM"
      expect_to_have_title(to_search_title)
      click_link "←"
      expect_to_have_title(users_index_title)
      click_link "Create DM"
      expect_to_have_title(to_search_title)
      # ユーザ名で検索ができる
      fill_in "direct_message_to", with: following_user.name
      click_button "検索"
      expect(page).to have_selector ".result", text: following_user.name
      # 閉じるボタンでDM宛先選択画面が閉じる
      find(".iziModal-button-close").click
      wait_for_css_disappear(".iziModal-button-close", 5) do 
        expect_to_not_have_title(to_search_title)
      end
    end
  end

  xscenario "DM宛先選択画面テスト", js: true do
    visit root_path
    
    log_in_as(me) do
      click_link "DM"
      click_link "Create DM"
      click_link "←"
      # # ★click_link "←"のあとモーダルが消えている
      # expect_to_have_title(users_index_title)

      # # ここでユーザ一覧画面が表示しきる前に次のCreate DMを
      # # 押そうとして押せずにモーダルが消える？

      # #find_link "Create DM"
      # click_link "Create DM"
      # expect_to_have_title(to_search_title)
      # #page.execute_script "$('#modal').iziModal('open')"

      # ## -----------------------------------
      # ## 以下フォローしているユーザについて
      # ## -----------------------------------
      # ## ユーザ名で検索ができる
      # #fill_in "#test_inp", with: "hoge"
      fill_in "direct_message_to", with: following_user.name  # →ここの入力がうまくいかない。
      take_screenshot
      #expect(page).to have_selector ".result", text: following_user.name

      ## 一意ユーザ名で検索ができる
      #fill_in "name", with: following_user.unique_name
      #expect(page).to have_selector ".result", text: following_user.unique_name
      ## -----------------------------------
      ## ここまで
      ## -----------------------------------

      ## -----------------------------------
      ## 以下フォローしていないユーザについて
      ## -----------------------------------
      ## ユーザ名で検索しても出さない
      #fill_in "name", with: unfollowing_user.name
      #expect(page).to_not have_selector ".result", text: unfollowing_user.name

      ## 一意ユーザ名で検索しても出さない
      #fill_in "name", with: unfollowing_user.unique_name
      #expect(page).to have_selector ".result", text: unfollowing_user.unique_name
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
