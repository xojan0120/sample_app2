require 'rails_helper'

RSpec.feature "FollowerNotification", type: :system do
  #↓perform_enqueued_jobsを使うために必要
  include ActiveJob::TestHelper

  let!(:user1)  { FactoryBot.create(:user, :with_follower_notification, name: "ユーザ1", unique_name: "John_smith",  follower_notification_enabled: false) }
  let!(:user2)  { FactoryBot.create(:user, :with_follower_notification, name: "ユーザ2", unique_name: "Jane_smith",  follower_notification_enabled: false) }
  let!(:user3)  { FactoryBot.create(:user, :with_follower_notification, name: "ユーザ3", unique_name: "Agent_smith", follower_notification_enabled: false) }

  scenario "設定画面の通知設定欄の確認", js: true do
    visit root_path
    log_in_as(user1) do
      visit_settings
      # フォロワー通知設定欄の初期表示がOFFになっているか検証する
      expect(page).to have_unchecked_field "Follower notification"
      # 設定欄をチェックしてプロフィール更新
      check "Follower notification"
      click_button "Save changes"
      # リロード
      visit current_path
      visit_settings
      # フォロワー通知設定欄がONになっているか検証する
      expect(page).to have_checked_field "Follower notification"
      # 設定欄のチェックをはずしてプロフィール更新
      uncheck "Follower notification"
      click_button "Save changes"
      # リロード
      visit current_path
      visit_settings
      # フォロワー通知設定欄がOFFになっているか検証する
      expect(page).to have_unchecked_field "Follower notification"
    end
  end

  scenario "通知機能について(設定OFFの場合)", js: true do
    user2.create_follower_notification
    user2.follower_notification.update_attribute(:enabled, false)

    visit root_path
    log_in_as(user1) do
      visit_users
      click_link user2.name

      # ユーザ1がユーザ2をフォローする
      click_follow

      # ユーザ2宛にメールが送信されていないことを検証する
      expect(ActionMailer::Base.deliveries.size).to eq 0
    end
  end

  scenario "通知機能について(設定ONの場合)", js: true do
    user2.create_follower_notification
    user2.follower_notification.update_attribute(:enabled, true)

    visit root_path
    log_in_as(user1) do
      visit_users
      click_link user2.name

      # メール送信はdeliver_laterで非同期処理される。
      # perform_enqueued_jobsのブロックで囲むことで、その中は
      # 同期処理される。
      perform_enqueued_jobs do
        # ユーザ1がユーザ2をフォローする
        click_follow
        # ユーザ2宛にメールが送信されていることを検証する
        expect(ActionMailer::Base.deliveries.size).to eq 1
      end
    end
  end

  scenario "連続通知制限機能について", js: true do
    user2.create_follower_notification
    user2.follower_notification.update_attribute(:enabled, true)

    visit root_path
    log_in_as(user1) do
      visit_users
      click_link user2.name

      perform_enqueued_jobs do
        # ユーザ1がユーザ2をフォローする
        click_follow
        # ユーザ2宛にメールが送信されていることを検証する
        expect(ActionMailer::Base.deliveries.size).to eq 1
      end

      perform_enqueued_jobs do
        # ユーザ1がユーザ2をアンフォローし、再びフォローする
        click_unfollow
        click_follow
        # ユーザ2宛にメールが送信されていないことを検証する
        expect(ActionMailer::Base.deliveries.size).to eq 1
      end

      # ユーザ1がフォローした際のFollowerNotificationLogのsent_mail_atを
      # フォロワー通知制限期間分、過去に遡らせる
      origin = user2.follower_notification.logs.find_by(follower: user1).mail_sent_at
      user2.follower_notification.logs.find_by(follower: user1).update_attribute(:mail_sent_at, origin - 1.day)
     
      perform_enqueued_jobs do
        # ユーザ1がユーザ2をアンフォローし、再びフォローする
        click_unfollow
        click_follow
        # ユーザ2宛にメールが送信されていることを検証する
        expect(ActionMailer::Base.deliveries.size).to eq 2
      end
    end
  end
end
