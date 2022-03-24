require 'rails_helper'

RSpec.describe Trip, type: :model do
  before do
    @trip = FactoryBot.build(:trip)
  end

  describe 'tripの保存' do
    context '新規投稿ができる場合' do
      it 'タイトル,都道府県,内容があれば投稿できる' do
        expect(@trip).to be_valid
      end
      it 'タイトル,都道府県があれば内容が空でも投稿できる' do
        @trip.content = ''
        expect(@trip).to be_valid
      end
    end

    context '新規投稿できない場合' do
      it 'タイトルが空では投稿できない' do
        @trip.title = ''
        @trip.valid?
        expect(@trip.errors.full_messages).to include("Title can't be blank")
      end
      it '都道府県が未選択(id=0)では投稿できない' do
        @trip.prefecture = Prefecture.all.find(id=0)
        @trip.valid?
        expect(@trip.errors.full_messages).to include("Prefecture can't be blank")
      end
      it 'ユーザーが紐づいていなければ投稿できない' do
        @trip.user = nil
        @trip.valid?
        expect(@trip.errors.full_messages).to include("User must exist")
      end
    end
  end
end
