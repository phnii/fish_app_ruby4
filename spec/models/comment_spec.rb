require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    @trip = FactoryBot.create(:trip)
    @user = @trip.user
    @another_user = FactoryBot.create(:user)
    @comment = FactoryBot.build(:comment)
  end

  describe 'コメントの新規投稿できるとき' do
    it '内容があれば投稿できる' do
      expect(@comment).to be_valid
    end
  end
  describe 'コメントの新規投稿ができないとき' do
    it '内容が空では投稿できない' do
      @comment.content = ''
      @comment.valid?
      expect(@comment.errors.full_messages).to include("Content can't be blank")
    end
    it 'ユーザーが紐づいていなければ投稿できない' do
      @comment.user = nil
      @comment.valid?
      expect(@comment.errors.full_messages).to include("User must exist")
    end
    it 'Tripが紐づいていなければ投稿できない' do
      @comment.trip = nil
      @comment.valid?
      expect(@comment.errors.full_messages).to include("Trip must exist")
    end
  end
end
