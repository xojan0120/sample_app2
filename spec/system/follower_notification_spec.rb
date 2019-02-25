require 'rails_helper'

RSpec.feature "FollowerNotification", type: :system do
  #↓perform_enqueued_jobsを使うために必要
  include ActiveJob::TestHelper

  let!(:user1)  { FactoryBot.create(:user, name: "ユーザ1", unique_name: "John_smith") }
  let!(:user2)  { FactoryBot.create(:user, name: "ユーザ2", unique_name: "Jane_smith") }
  let!(:user3)  { FactoryBot.create(:user, name: "ユーザ3", unique_name: "Agent_smith") }

  fscenario "設定画面の通知設定欄の確認", js: true do
    visit root_path
    log_in_as(user1) do
      visit_settings

      # フォロワー通知設定欄の初期表示がOFFになっているか検証する
      expect(page).to have_unchecked_field "Follower notification"
    end
  end

  scenario "通知機能について(設定OFFの場合)", js: true do
    visit root_path
    log_in_as(user1) do
      visit_users
      click_link user2.name

      # ユーザ1がユーザ2をフォローする
      perform_enqueued_jobs do
        click_button "Follow"
      end

      # ユーザ2宛にメールが送信されていないことを検証する
      expect(ActionMailer::Base.deliveries.size).to eq 0
    end
  end

  scenario "通知機能について(設定ONの場合)", js: true do
    visit root_path
    log_in_as(user1) do
      visit_users
      click_link user2.name

      # ユーザ1がユーザ2をフォローする
      perform_enqueued_jobs do
        click_button "Follow"
      end

      # ユーザ2宛にメールが送信されていることを検証する
      expect(ActionMailer::Base.deliveries.size).to eq 1
      mail = ActionMailer::Base.deliveries.last
      aggregate_failures do
        expect(mail.to).to eq      [user2.email]
        expect(mail.from).to eq    ["noreply@example.com"]
        expect(mail.subject).to eq "Followed Notification"
        expect(mail.body).to match "Hi, #{user2.name}"
        expect(mail.body).to match "followed by #{user1.name}"
      end

      # ユーザ1がユーザ2をアンフォローし、再びフォローする
      perform_enqueued_jobs do
        click_button "Unfollow"
        click_button "Follow"
      end

      # ユーザ2宛にメールが送信されていないことを検証する
      expect(ActionMailer::Base.deliveries.size).to eq 1

      # ユーザ1がフォローした際のFollowerNotificationLogのcreated_atを1日経過後に更新する
      origin = user2.follower_notification.logs.find_by(user: user1).mail_sent_at
      user2.follower_notification.logs.find_by(user: user1).update_attribute(:mail_sent_at, origin + 1.day)
     
      # ユーザ1がユーザ2をアンフォローし、再びフォローする
      perform_enqueued_jobs do
        click_button "Unfollow"
        click_button "Follow"
      end

      # ユーザ2宛にメールが送信されていることを検証する
      expect(ActionMailer::Base.deliveries.size).to eq 2
      mail = ActionMailer::Base.deliveries.last
      aggregate_failures do
        expect(mail.to).to eq      [user2.email]
        expect(mail.from).to eq    ["noreply@example.com"]
        expect(mail.subject).to eq "Followed Notification"
        expect(mail.body).to match "Hi, #{user2.name}"
        expect(mail.body).to match "followed by #{user1.name}"
      end
    end
  end
end
