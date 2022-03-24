require 'rails_helper'

RSpec.describe "Rooms", type: :system do
  before do
    @rel = FactoryBot.create(:relationship)
    @user = @rel.user
    @follow = @rel.follow
    @rel_reverse = Relationship.create(user: @follow, follow: @user)
  end

  context '新規ルーム作成できるとき' do
    it '相互フォロー状態で相手のフォローリストページのメッセージボタンを押すと新規ルームが作成されてメッセージ一覧ページに遷移する' do
      # ログインする
      sign_in(@user)
      # フォロー相手のフォローリストページに移動する
      visit follow_list_user_path(@follow)
      # メッセージボタンが表示されていることを確認する
      expect(page).to have_selector('input[id="message_btn"]')
      # メッセージボタンをクリックするとRoomモデルカウントが1つ、RoomUserモデルカウントが2つ増加する
      expect{
        find('input[id="message_btn"]').click
      }.to change {Room.count}.by(1).and change {RoomUser.count}.by(2)
      # メッセージ一覧ページに遷移したことを確認する
      room = @user.rooms.first
      expect(current_path).to eq room_messages_path(room)
      # 相互フォロー関係にある2人のユーザーが新規作成されたRoomと紐づいていることを確認する
      expect(room.users).to include(@user)
      expect(room.users).to include(@follow)
    end
  end
  context '新規ルームが作成できないとき' do
    it '自分はフォローしていても相手からフォローされていないときはメッセージボタンが表示されない' do
      # 相互フォロー状態を解除する
      @rel_reverse.destroy
      # ログインする
      sign_in(@user)
      # フォロー相手のフォローリストページに移動する
      visit follow_list_user_path(@follow)
      # メッセージボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="message_btn"]')
    end
    it '相手は自分をフォローしていても自分は相手をフォローしていないときはメッセージボタンが表示されない' do
      # 相互フォロー状態を解除する
      @rel.destroy
      # ログインする
      sign_in(@user)
      # 自分のことをフォローしているユーザーのフォローリストページに移動する
      visit follow_list_user_path(@follow)
      # メッセージボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="message_btn"]')
    end
    it '既Roomが作成済みの場合メッセージボタンをクリックしてもRoomは新規作成しないでメッセージ一覧ページに遷移する' do
      room = Room.create(user_ids: [@user.id, @follow.id])
      # ログインする
      sign_in(@user)
      # フォロー相手のフォローリストページに移動する
      visit follow_list_user_path(@follow)
      # メッセージボタンが表示されていることを確認する
      expect(page).to have_selector('input[id="message_btn"]')
      # メッセージボタンをクリックするとRoomとRoomUserのモデルカウントが変化しないことを確認する
      expect{
        find('input[id="message_btn"]').click
      }.to change {Room.count}.by(0).and change {RoomUser.count}.by(0)
      # メッセージ一覧ページに遷移したことを確認する
      expect(current_path).to eq room_messages_path(room)
    end
  end
end
