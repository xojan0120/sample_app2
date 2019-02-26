require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "follower_notification" do
    let(:follow_user)   { FactoryBot.create(:user) }
    let(:followed_user) { FactoryBot.create(:user, :with_follower_notification) }
    let(:mail) { UserMailer.follower_notification(follow_user, followed_user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Followed Notification")
      expect(mail.to).to eq([followed_user.email])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the body" do
      expect(html_body(mail)).to match "Hi #{followed_user.name}"
      expect(html_body(mail)).to match "followed by #{follow_user.name}"
    end
  end
end
