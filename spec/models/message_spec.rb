require 'rails_helper'

RSpec.describe Message, type: :model do
  before do
    @message = FactoryBot.build(:message)
  end
  describe '新規メッセージ投稿' do
    context '新規メッセージ投稿ができるとき' do
      it '内容が入力されたら投稿できる' do
        expect(@message).to be_valid
      end
    end
    context '新規メッセージ投稿ができないとき' do
      it '内容が空では投稿できない' do
        @message.content = ''
        @message.valid?
        expect(@message.errors.full_messages).to include("Content can't be blank")
      end
      it 'ユーザーが紐づいていなければ投稿できない' do
        @message.user = nil
        @message.valid?
        expect(@message.errors.full_messages).to include("User must exist")
      end
      it 'ルームが紐づいていなければ投稿できない' do
        @message.room = nil
        @message.valid?
        expect(@message.errors.full_messages).to include("Room must exist")
      end
    end
  end
end
