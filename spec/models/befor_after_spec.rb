require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  # :suite系はspec/rails_helper.rbなどの
  # Rspec.configureブロック内でしか使えない
  #
  # after(:suite) do
  #   puts "run after(:suite)"
  # end
  # before(:suite) do
  #   puts "run before(:suite)"
  # end

  describe "機能Aについて" do
    before do
      puts "run before(:each)"
    end
    before(:all) do
      puts "run before(:all)"
    end

    context "状態aのとき" do
      it do
        puts "テスト1"
      end
      it do
        puts "テスト2"
      end
    end
    context "状態bのとき" do
      it do
        puts "テスト1"
      end
      it do
        puts "テスト2"
      end
    end
  end

  describe "機能Bについて" do
    after do
      puts "run after(:each)"
    end
    after(:all) do
      puts "run after(:all)"
    end

    context "状態aのとき" do
      it do
        puts "テスト1"
      end
      it do
        puts "テスト2"
      end
    end
    context "状態bのとき" do
      it do
        puts "テスト1"
      end
      it do
        puts "テスト2"
      end
    end
  end
end
