require 'rails_helper'

RSpec.describe "メッセージの新規投稿", type: :system do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @rel = Relationship.create(user: @user1, follow: @user2)
    @rel_reverse = Relationship.create(user: @user2, follow: @user1)
    @room = Room.create(user_ids: [@user1.id, @user2.id])
    @message = Message.create(content: 'TEST', user_id: @user1.id, room_id: @room.id)
    @message_content = 'test message content'
  end
  context 'メッセージの新規作成ができる' do
    it '相互フォロー状態でメッセージ一覧ページで内容を入力するとの新規投稿ができる' do
      # ログインする
      sign_in(@user1)
      # メッセージ一覧ページに移動する
      visit room_messages_path(@room)
      # メッセージ入力フォームが表示されていることを確認する
      expect(page).to have_selector('textarea[name="message[content]"]')
      # メッセージを入力する
      fill_in 'message[content]', with: @message_content
      # 送信ボタンをクリックするとMessageモデルカウントが1つ増加することを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Message.count}.by(1)
      # メッセージ一覧ページにいることを確認する
      expect(current_path).to eq room_messages_path(@room)
      # 新規投稿したメッセージ内容が表示されていることを確認する
      expect(page).to have_content(@message_content)
    end
  end
  context 'メッセージの新規作成ができない' do
    it '相互フォロー状態でなくかつRoomインスタンスが未作成の場合メッセージボタンが表示されない' do
      # 相互フォロ状態ーを解除する
      @rel_reverse.destroy
      # Roomインスタンスを削除する
      @room.destroy
      # ログインする
      sign_in(@user1)
      # フォロー相手のフォローリストページに移動する
      visit follow_list_user_path(@user2)
      # メッセージボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="message_btn"]')
    end
    it 'Roomインスタンス作成後に相互フォロー状態が解除されたときメッセージ一覧ページに投稿フォームが表示されない' do
      # 相互フォロー状態を解除する
      @rel_reverse.destroy
      # ログインする
      sign_in(@user1)
      # フォロー相手のフォローリストページに移動する
      visit follow_list_user_path(@user2)
      # メッセージボタンが表示されていることを確認する
      expect(page).to have_selector('input[id="message_btn"]')
      # メッセージボタンをクリックしてもRoomとRoomUserモデルカウントは変化せずメッセージ一覧ページに遷移する
      expect{
        find('input[id="message_btn"]').click
      }.to change {Message.count}.by(0)
      # メッセージ一覧ページにいることを確認する
      expect(current_path).to eq room_messages_path(@room)
      # 投稿済みメッセージが表示されていることを確認する
      expect(page).to have_content(@message.content)
      # メッセージ入力フォームが表示されていないことを確認する
      expect(page).to have_no_selector('textarea[name="message[content]"]')
      # "※ メッセージの送信は相互フォロー状態でのみ可能です"と表示されていることを確認する
      expect(page).to have_content('※ メッセージの送信は相互フォロー状態でのみ可能です')
    end
  end
end
