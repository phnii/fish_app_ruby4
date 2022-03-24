require 'rails_helper'

RSpec.describe Trip, type: :model do
  before do
    @result = FactoryBot.build(:result)
  end
  describe 'resultの保存' do
    context '新規投稿ができる場合' do
      it '魚名,画像があれば投稿できる' do
        expect(@result).to be_valid
      end
      it '魚名があれば画像が空でも投稿できる' do
        @result.image = nil
        expect(@result).to be_valid
      end
    end

    context '新規投稿できない場合' do
      it '魚名が空では投稿できない' do
        @result.fish_name = ''
        @result.valid?
        expect(@result.errors.full_messages).to include("Fish name is invalid. Use full-width katakana characters")
      end
      it '魚名が平仮名では投稿できない' do
        @result.fish_name = 'てすと'
        @result.valid?
        expect(@result.errors.full_messages).to include("Fish name is invalid. Use full-width katakana characters")
      end
      it '魚名が漢字では投稿できない' do
        @result.fish_name = '鯖'
        @result.valid?
        expect(@result.errors.full_messages).to include("Fish name is invalid. Use full-width katakana characters")
      end
      it 'tripが紐づいていなければ登録できない' do
        @result.trip = nil
        @result.valid?
        expect(@result.errors.full_messages).to include("Trip must exist")
      end
    end
  end
end
