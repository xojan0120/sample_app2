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

  def expect_to_not_have_title(page)
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
      find(".back_link_icon").click
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

  scenario "DM一覧画面テスト(ユーザ1とユーザ2間のメッセージ送信)", js: true do
    user1 = me
    user2 = following_user
    user2.follow(user1)

    # ユーザ1用のセッションを作成する
    using_session :user1 do
      visit root_path
      log_in_as(user1, log_out_user: false) do
        click_link "DM"
        click_link "Create DM"

        # DM宛先選択画面から検索してユーザ2を選択し、DM一覧画面が表示される
        fill_in "to_search_form", with: user2.name
        expect(page).to have_selector "#result", text: user2.name
        find(%Q( [data-user-id="#{user2.id}"] )).click
        expect_to_have_title(user2.name)

        # 戻るリンクでDM宛先選択画面に戻る
        find(".back_link_icon").click
        expect_to_have_title(to_select_title)

        # 再びDM宛先選択画面からユーザ2を検索しDM一覧画面を表示する
        fill_in "to_search_form", with: user2.name
        expect(page).to have_selector "#result", text: user2.name
        find(%Q( [data-user-id="#{user2.id}"] )).click
      end
    end

    # ユーザ2用のセッションを作成する
    using_session :user2 do
      visit root_path
      log_in_as(user2, log_out_user: false) do
        click_link "DM"
        click_link "Create DM"

        # DM宛先選択画面から検索してユーザ1を選択し、DM一覧画面が表示される
        fill_in "to_search_form", with: user1.name
        expect(page).to have_selector "#result", text: user1.name
        find(%Q( [data-user-id="#{user1.id}"] )).click
        expect_to_have_title(user1.name)
      end
    end

    # ユーザ1用のセッションに対して
    msg1 = "こんにちわ,#{user2.name}"
    using_session :user1 do
      # メッセージを入力
      fill_in "direct_message[content]", with: msg1

      # 画像をセット
      expect(page).to have_css(".glyphicon-picture")
      image_path = 'spec/factories/images/rails.png'
      image_full_path = Rails.root.join(image_path)
      attach_file('direct_message[picture]', image_full_path, visible: false)

      # 送信後、メッセージと画像が表示される
      find(".glyphicon-send").click
      expect(page).to have_selector "ul.messages", text: msg1
      within "ul.messages" do
        expect(page).to have_selector("img", count: 1)
      end
    end

    # ユーザ2用のセッションに対して
    msg2 = "やあ、#{user1.name}"
    using_session :user2 do
      expect(page).to have_selector "ul.messages", text: msg1
      within "ul.messages" do
        expect(page).to have_selector("img", count: 1)
      end

      # メッセージを入力
      fill_in "direct_message[content]", with: msg2

      # 画像をセット
      expect(page).to have_css(".glyphicon-picture")
      image_path = 'spec/factories/images/rails.png'
      image_full_path = Rails.root.join(image_path)
      attach_file('direct_message[picture]', image_full_path, visible: false)

      # 送信後、メッセージと画像が表示される
      find(".glyphicon-send").click
      expect(page).to have_selector "ul.messages", text: msg2
      within "ul.messages" do
        expect(page).to have_selector("img", count: 2)
      end
    end

    # ユーザ1用のセッションに対して
    using_session :user1 do
      expect(page).to have_selector "ul.messages", text: msg2
      within "ul.messages" do
        expect(page).to have_selector("img", count: 2)
      end
    end

    # ユーザ1用のセッションに対して
    using_session :user1 do
      # 閉じるボタンでDM一覧画面が閉じる
      close_modal
      expect_to_not_have_title(user2.name)
      log_out
    end

    # ユーザ2用のセッションに対して
    using_session :user2 do
      # 閉じるボタンでDM一覧画面が閉じる
      close_modal
      expect_to_not_have_title(user1.name)
      log_out
    end
  end


  scenario "DM一覧画面テスト(過去にやりとりしたことがあるユーザ一覧)", js: true do
    # 事前に送信ユーザ1から宛先ユーザ1～11にDM送信したデータを作成する。  
    # 送信データは宛先ユーザ1～11の順で作り、宛先ユーザ11が最新のDMとなっている。
    fr_user1 = FactoryBot.create(:user)
    to_users = FactoryBot.create_list(:user, 11).sort
    t = Time.now
    to_users.each do |to_user|
      room = Room.make([fr_user1, to_user])
      dm = fr_user1.send_dm(room, "hello, #{to_user.name}")
      dm.update_attribute(:created_at, t += 1)
    end
    to_user1     = to_users.first #User.where.not(user: fr_user1)
    to_users2_11 = to_users[1..10]
    to_user2     = to_users2_11[0]

    visit root_path
    log_in_as(fr_user1) do
      # DM宛先選択画面からユーザ2を検索しDM一覧画面を表示する
      click_link "DM"

      # DMユーザ一覧画面の過去にやりとりをしたことがあるユーザ一覧について
      within "#latest_dm_users" do
        # 宛先ユーザ1が表示されていないことを検証する
        expect(page).to_not have_content(to_user1.name)
        # 宛先ユーザ2～11が表示されていることを検証する
        to_users2_11.each do |to_user|
          expect(page).to have_content(to_user.name)
        end

        # ユーザ一覧覧の宛先ユーザ2をクリックする
        find(%Q( [data-user-id="#{to_user2.id}"] )).click
      end
      # 宛先ユーザ2のDM一覧画面が表示されることを検証する
      expect_to_have_title(to_user2.name)

      close_modal
    end
  end

  scenario "DM一覧画面テスト(メッセージ削除)", js: true do
    user1 = me
    user2 = following_user
    user2.follow(me)
    msg = "削除テスト"

    visit root_path
    log_in_as(user1) do
      click_link "DM"
      click_link "Create DM"

      # DM宛先選択画面から検索してユーザ2を選択し、DM一覧画面表示
      fill_in "to_search_form", with: user2.name
      find(%Q( [data-user-id="#{user2.id}"] )).click

      # メッセージを入力・送信
      fill_in "direct_message[content]", with: msg
      sleep 0.5
      find(".glyphicon-send").click
      msg_id = DirectMessage.find_by(content: msg).id

      # 入力したメッセージのゴミ箱アイコンをクリックする
      find(".glyphicon-trash").click
      # 確認メッセージが表示されていることを検証する
      expect(page).to have_content("delete?")
      # 確認メッセージのキャンセルボタンをクリックする
      click_button "Cancel"
      # メッセージが消えていないことを検証する
      expect(page).to have_content(msg)

      # 入力したメッセージのゴミ箱アイコンをクリックする
      find(".glyphicon-trash").click
      # 確認メッセージのキャンセルボタンをクリックする
      click_button "OK"
      # メッセージが消えていないことを検証する
      expect(page).to_not have_content(msg)

      close_modal
    end

    log_in_as(user2) do
      click_link "DM"
      click_link "Create DM"

      # DM宛先選択画面から検索してユーザ1を選択し、DM一覧画面表示
      fill_in "to_search_form", with: user1.name
      find(%Q( [data-user-id="#{user1.id}"] )).click

      # DM一覧画面にユーザ1が削除したメッセージが消えていないことを検証する
      expect(page).to have_content(msg)

      close_modal
    end
  end

end
