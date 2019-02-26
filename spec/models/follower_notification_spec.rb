require 'rails_helper'

RSpec.describe FollowerNotification, type: :model do
  # UserMailerSpecにてテストする
  #it "通知メールを送信できること" do
  #  follow_user   = FactoryBot.create(:user)
  #  followed_user = FactoryBot.create(:user, :with_follower_notification)
  #  expect {
  #    FollowerNotification.send_mail(follow_user, followed_user)
  #  }.to change(ActionMailer::Base.deliveries, :size).by(1)
  #end
end
