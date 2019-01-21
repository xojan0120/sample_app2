require 'rails_helper'

RSpec.feature "MultipleReply", type: :system do

  let!(:sender) { FactoryBot.create(:user, unique_name: "Mr_Sender") }
  let!(:receiver1) { FactoryBot.create(:user, unique_name: "Ms_Receiver1") }
  let!(:receiver2) { FactoryBot.create(:user, unique_name: "Ms_Receiver2") }
  let!(:other) { FactoryBot.create(:user) }

  scenario "ユーザは2人に返信ができて、削除もできる", js: true do
    msg = "@#{receiver1.unique_name} @#{receiver2.unique_name} こんにちわ"

    visit root_path

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
