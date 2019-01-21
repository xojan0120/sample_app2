require 'rails_helper'

RSpec.feature "SingleReply", type: :system do
  let!(:sender) { FactoryBot.create(:user, unique_name: "Mr_Sender") }
  let!(:receiver) { FactoryBot.create(:user, unique_name: "Ms_Receiver") }
  let!(:other) { FactoryBot.create(:user) }

  scenario "返信ができて、削除もできる", js: true do
    msg = "@#{receiver.unique_name} こんにちわ"

    visit root_path

    #log_in_as sender
    #visit_home
    #post_content msg
    #log_out
   
    # 送信者コメント
    log_in_as(sender) do
      visit_home
      post_content msg
    end

    # 受信者のHomeに返信がある
    log_in_as(receiver) do
      visit_home
      expect(page).to have_content msg
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

    # 受信者のHomeからも返信が削除されている
    log_in_as(receiver) do
      visit_home
      expect(page).to_not have_content msg
    end

  end
end
