require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT)

RSpec.describe Micropost, type: :model do
  it "ユーザに紐付いていれば有効であること" do
    micropost = FactoryBot.build(:micropost)
    expect(micropost).to be_valid
  end

  it "ユーザに紐付いていなければ無効であること" do
    micropost = FactoryBot.build(:micropost)
    micropost.user_id = nil
    expect(micropost).to be_invalid
  end

  it "投稿文があれば有効であること" do
    micropost = FactoryBot.build(:micropost, content:"test")
    expect(micropost).to be_valid
  end

  it "投稿文がなければ無効であること" do
    micropost = FactoryBot.build(:micropost, content:nil)
    expect(micropost).to be_invalid
  end

  it "投稿文が140文字以下なら有効であること" do
    micropost = FactoryBot.build(:micropost, content: "a"*140)
    expect(micropost).to be_valid
  end

  it "投稿文が141文字以上なら無効であること" do
    micropost = FactoryBot.build(:micropost, content: "a"*141)
    expect(micropost).to be_invalid
  end

  describe "投稿の取得順序について" do
    let(:user)             { FactoryBot.create(:user) }
    let(:today)            { Date.today.to_time       }
    let(:yesterday)        { Date.today.days_ago(1)   }
    let(:before_yesterday) { Date.today.days_ago(2)   }
    before do
      user.microposts.create(content: "first post",  created_at: before_yesterday)
      user.microposts.create(content: "second post", created_at: yesterday)
      user.microposts.create(content: "third post",  created_at: today)
    end
    context "デフォルトスコープでは" do
      it "投稿は作成日時の一番新しいものから取得できること" do
        expect(user.microposts.first.created_at).to eq today
      end
    end
    context "デフォルトスコープを解除した状態では" do
      it "投稿は作成日時の一番古いものから取得できること" do
        expect(user.microposts.unscoped.first.created_at).to eq before_yesterday
      end
    end
  end

  describe "投稿画像について" do
    context "ファイルサイズが5MB以下の場合" do
      it "有効である" do
        picture = fixture_file_upload(
                                        Settings.test_image.rails_logo.path,
                                        Settings.test_image.rails_logo.mime
                                      )
        micropost = FactoryBot.build(:micropost, picture: picture)
        expect(micropost.picture).to be_truthy
        expect(micropost).to be_valid
      end
    end
    context "ファイルサイズが5MBより大きい場合" do
      it "無効である" do
        picture = fixture_file_upload(
                                        Settings.test_image.filesize_6mb.path,
                                        Settings.test_image.filesize_6mb.mime
                                      )
        micropost = FactoryBot.build(:micropost, picture: picture)
        expect(micropost.picture).to be_truthy
        expect(micropost).to be_invalid
      end
    end
  end


  describe "返信先の登録機能について" do
    context "文中に@一意ユーザ名が無い場合" do
      it "返信は登録されない" do
        expect {
          micropost = FactoryBot.create(:micropost)
        }.to_not change(Reply, :count)
      end
    end

    context "文中に@一意ユーザ名がある場合" do
      it "返信は登録される" do
        expect {
          other_user1 = FactoryBot.create(:user)
          other_user2 = FactoryBot.create(:user)
          micropost = FactoryBot.create(:micropost, content: "@#{other_user1.unique_name} @#{other_user2.unique_name}さん、こんにちわ")
        }.to change(Reply, :count).by(2)
      end
    end
  end

  describe "投稿文中から@一意ユーザ名抽出機能について" do
    context "文中に@一意ユーザ名が無い場合" do
      it "空の配列を返す" do
        unique_name = "JohnSmith"
        content = "こんにちわ#{unique_name}さん"
        micropost = FactoryBot.build(:micropost, content: content)
        expect(micropost.unique_names).to be_empty
      end
    end

    context "文中に@一意ユーザ名が1つある場合" do
      it "配列で抽出できる" do
        unique_name = "JohnSmith"
        content = "こんにちわ@#{unique_name}さん"
        unique_names = [unique_name].map{|v| v.downcase }
        micropost = FactoryBot.build(:micropost, content: content)
        expect(micropost.unique_names).to match_array(unique_names)
      end
    end

    context "文中に@一意ユーザ名が2つ以上ある場合" do
      it "配列で抽出できる" do
        unique_name1 = "JohnSmith"
        unique_name2 = "JaneSmith"
        content = "こんにちわ@#{unique_name1}さん、@#{unique_name2}さん"
        unique_names = [unique_name1,unique_name2].map{|v| v.downcase }
        micropost = FactoryBot.build(:micropost, content: content)
        expect(micropost.unique_names).to match_array(unique_names)
      end
    end
  end

  describe "including_repliesメソッドについて" do
    let(:me) { FactoryBot.create(:user) }

    context "フォロー人数が0の場合" do
      it "自分の投稿が全て取得できる" do
        FactoryBot.create(:micropost, user: me)
        FactoryBot.create(:micropost, user: me)
        expect(me.feed).to match_array(me.microposts)
      end

      it "自分宛の投稿が全て取得できる" do
        replies =  [FactoryBot.create(:micropost, :with_reply, reply_to: me.id)]
        replies << FactoryBot.create(:micropost, :with_reply, reply_to: me.id)
        expect(me.feed).to match_array(replies)
      end
    end
    
    context "フォロー人数が1以上の場合" do
      it "自分とフォローしている人の投稿が全て取得できる" do
        other = FactoryBot.create(:user)
        me.follow(other)
        FactoryBot.create(:micropost, user: me)
        FactoryBot.create(:micropost, user: other)

        microposts = me.microposts + other.microposts
        expect(me.feed).to match_array(microposts)
      end

      it "自分、フォローしている人、自分宛の投稿が全て取得できる" do

        FactoryBot.create(:micropost, user: me)

        followed = FactoryBot.create(:user)
        me.follow(followed)
        FactoryBot.create(:micropost, user: followed, content: "こんにちわ")

        replied_other = FactoryBot.create(:user)
        FactoryBot.create(:micropost, user: replied_other, content: "@#{me.unique_name},@#{followed.unique_name} hello")

        microposts = me.microposts + followed.microposts + replied_other.microposts
        expect(me.feed).to match_array(microposts)
      end
    end
  end
end
