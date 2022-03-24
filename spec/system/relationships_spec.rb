require 'rails_helper'

RSpec.describe "Relationships", type: :system do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
  end

  context '新規フォロー関係が作成できるとき' do
    it 'ユーザーは他のユーザーをフォローするとフォローリストページに遷移する' do
      # ログインする
      sign_in(@user1)
      # 他のユーザーのフォローリストページに移動する
      visit follow_list_user_path(@user2)
      # フォローするボタンが表示されていることを確認する
      expect(page).to have_selector('input[id="follow_create_btn"]')
      # フォローボタンをクリックするとRelationshipモデルカウントが1つ増加する
      expect{
        find('input[id="follow_create_btn"]').click
      }.to change {Relationship.count}.by(1)
      # 相手のフォローリストページにいることを確認する
      expect(current_path).to eq follow_list_user_path(@user2)
      # "以下のユーザーによってフォローされています(1)"と表示されていることを確認する
      expect(page).to have_content("以下のユーザーによってフォローされています(#{@user2.followers.count})")
      # 自分のユーザー名が表示されていることを確認する
      expect(page).to have_content("#{@user1.name} (投稿数 : #{@user1.trips.count})")
      # フォローを外すボタンが表示されていることを確認する
      expect(page).to have_selector('input[id="follow_delete_btn"]')
      # フォローするボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="follow_create_btn"]')
    end
  end
  context '新規フォロー関係が作成できないとき' do
    it 'ユーザーは自分自身をフォローできない' do
      # ログインする
      sign_in(@user1)
      # 自身のフォローリストページに移動する
      visit follow_list_user_path(@user1)
      # フォローするボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="follow_create_btn"]')
    end
    it 'ログアウト状態ではフォローできない' do
      visit follow_list_user_path(@user1)
      # フォローするボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="follow_create_btn"]')
    end
    it '既にフォロー済みの相手はフォローできない' do
      rel = FactoryBot.create(:relationship)
      # ログインする
      sign_in(rel.user)
      # フォロー済みの相手のフォローリストページに移動する
      visit follow_list_user_path(rel.follow)
      # フォローするボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="follow_create_btn"]')
    end
  end
end

RSpec.describe "フォロー関係の削除", type: :system do
  before do
    @rel = FactoryBot.create(:relationship)
    @user = @rel.user
    @follow = @rel.follow
  end
  context 'フォロー関係を削除できるとき' do
    it '既にフォロー済みの相手をフォロー解除できる' do
      # ログイン
      sign_in(@user)
      # フォロー中の相手のフォローリストページに移動する
      visit follow_list_user_path(@follow)
      # フォローを外すボタンが表示されていることを確認する
      expect(page).to have_selector('input[id="follow_delete_btn"]')
      # フォローを外すボタンをクリックするとRelationモデルカウントが1つ減少することを確認する
      expect{
        find('input[id="follow_delete_btn"]').click
      }.to change {Relationship.count}.by(-1)
      # "以下のユーザーによってフォローされています(0)"と表示されていることを確認する
      expect(page).to have_content("以下のユーザーによってフォローされています(#{@follow.followers.count})")
      # 自分の名前が表示されていないことを確認する
      expect(page).to have_no_content("#{@user.name} (投稿数 : #{@user.trips.count})")
      # フォローを外すボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="follow_delete_btn"]')
      # フォローするボタンが表示されていることを確認する
      expect(page).to have_selector('input[id="follow_create_btn"]')
    end
  end
  context 'フォロー関係を削除できないとき' do
    it 'ログアウト状態ではフォロー解除できない' do
      # フォローリストページに移動する
      visit follow_list_user_path(@follow)
      # フォローを外すボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="follow_delete_btn"]')
    end
  end
end