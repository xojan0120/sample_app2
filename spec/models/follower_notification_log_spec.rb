require 'rails_helper'

RSpec.describe FollowerNotificationLog, type: :model do
  it { is_expected.to validate_presence_of :follower_id           }
  it { is_expected.to validate_presence_of :mail_sent_at          }
  it { is_expected.to validate_presence_of :follower_notification }

  it "フォロワーID、メール送信日時、フォロワー通知設定があれば有効な状態であること" do
    follow_user   = FactoryBot.create(:user)
    followed_user = FactoryBot.create(:user, :with_follower_notification)
    log = FollowerNotificationLog.create(follower:              follow_user,
                                         mail_sent_at:          Time.now,
                                         follower_notification: followed_user.follower_notification
                                        )
    expect(log).to be_valid
  end

  it "ログを新規作成できること" do
    follow_user   = FactoryBot.create(:user)
    followed_user = FactoryBot.create(:user, :with_follower_notification)
    time          = Time.now
    log = FollowerNotificationLog.create_or_update(follow_user, followed_user, time)

    expect(log).to be_valid
  end

  it "ログを更新できること" do
    follow_user   = FactoryBot.create(:user)
    followed_user = FactoryBot.create(:user, :with_follower_notification)
    time          = Time.zone.now

    # 新規
    FollowerNotificationLog.create_or_update(follow_user, followed_user, time)

    # 更新
    new_time = time + 1.day
    FollowerNotificationLog.create_or_update(follow_user, followed_user, new_time)

    log = FollowerNotificationLog
              .find_by(follower:              follow_user,
                       follower_notification: followed_user.follower_notification
                      )

    expect(log.mail_sent_at.to_i).to eq new_time.to_i

    #expect(log.mail_sent_at).to eq new_time
    # ↑だと↓のように、log\mail_sent_atの秒以下の一部が丸められてしまい一致しなくなる
    # Failure/Error: expect(log.mail_sent_at).to eq new_time
    #  
    #    expected: 2019-02-27 14:17:33.823170391 +0900
    #         got: 2019-02-27 14:17:33.823170000 +0900
    #  
    #    (compared using ==)

  end
end
