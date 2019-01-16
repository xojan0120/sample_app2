require 'rails_helper'

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
    micropost = FactoryBot.build(:micropost)
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

  describe "投稿文中から@一意ユーザ名抽出機能について" do

    context "文中に@一意ユーザ名が無い場合" do
      it "空の配列を返す" do
      end
    end

    context "文中に@一意ユーザ名が1つある場合" do
      context "@一意ユーザ名が文頭にある場合" do
        it "配列で抽出できる" do
          unique_name = "JohnSmith"
          content = "@#{unique_name}ハロー"
          unique_names = [unique_name].map{|v| v.downcase }
          micropost = FactoryBot.build(:micropost, content: content)
          expect(micropost.unique_names).to match_array(unique_names)
        end
      end
      context "@一意ユーザ名が文中にある場合" do
        it "配列で抽出できる" do
          unique_name = "JohnSmith"
          content = "こんにちわ@#{unique_name}ハロー"
          unique_names = [unique_name].map{|v| v.downcase }
          micropost = FactoryBot.build(:micropost, content: content)
          expect(micropost.unique_names).to match_array(unique_names)
        end
      end
      context "@一意ユーザ名が文末にある場合" do
        it "配列で抽出できる" do
          unique_name = "JohnSmith"
          content = "こんにちわ@#{unique_name}"
          unique_names = [unique_name].map{|v| v.downcase }
          micropost = FactoryBot.build(:micropost, content: content)
          expect(micropost.unique_names).to match_array(unique_names)
        end
      end
      context "@一意ユーザ名のみの場合" do
        it "配列で抽出できる" do
          unique_name = "JohnSmith"
          content = "@#{unique_name}"
          unique_names = [unique_name].map{|v| v.downcase }
          micropost = FactoryBot.build(:micropost, content: content)
          expect(micropost.unique_names).to match_array(unique_names)
        end
      end
    end

    context "文中に@一意ユーザ名が2つ以上ある場合" do
      context "@一意ユーザ名が文頭にある場合" do
        it "配列で抽出できる" do
          unique_name1 = "JohnSmith"
          unique_name2 = "JaneSmith"
          content = "@#{unique_name1} @#{unique_name2}ハロー"
          unique_names = [unique_name1,unique_name2].map{|v| v.downcase }
          micropost = FactoryBot.build(:micropost, content: content)
          expect(micropost.unique_names).to match_array(unique_names)
        end
      end
      xcontext "@一意ユーザ名が文中にある場合" do
        it "配列で抽出できる" do
        end
      end
      xcontext "@一意ユーザ名が文末にある場合" do
        it "配列で抽出できる" do
        end
      end
      xcontext "@一意ユーザ名のみの場合" do
        it "配列で抽出できる" do
        end
      end
    end
  end
end
