require 'rails_helper'

RSpec.describe Relationship, type: :model do
  before do
    @relationship = Relationship.new
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
  end

  describe '新規フォロー関係作成' do
    context '新規作成ができるとき' do
      it 'userとfollowの組み合わせが同じRelationshipのインスタンスが存在しないとき作成できる' do
        @relationship.user = @user1
        @relationship.follow = @user2
        expect(@relationship).to be_valid
      end
    end
    context '新規作成できないとき' do
      it '紐づくuserが空では作成できない' do
        @relationship.user = nil
        @relationship.follow = @user2
        expect(@relationship).to be_invalid
      end
      it '紐づくfollowが空では作成できない' do
        @relationship.user = @user1
        @relationship.follow = nil
        expect(@relationship).to be_invalid 
      end
    end
  end
end
