require 'rails_helper'

RSpec.describe "コメントの新規投稿", type: :system do
  before do
    @trip = FactoryBot.create(:trip)
    @user = FactoryBot.create(:user)
    @message_content = 'test message content'
  end

  context 'コメントの新規投稿ができる' do
    it '投稿詳細ページでコメントを入力して投稿すると投稿詳細ページにリダイレクトする' do
      # ログインする
      sign_in(@user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # コメント入力フォームが表示されていることを確認する
      expect(page).to have_selector('textarea[name="comment[content]"]') 
      # コメント内容を入力する
      fill_in 'comment[content]', with: @message_content
      # 送信ボタンをクリックしてCommentモデルカウントが1つ増加することを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Comment.count}.by(1)
      # 投稿詳細ページにリダイレクトされたことを確認する
      expect(current_path).to eq trip_path(@trip)
      # 投稿したコメントが表示されていることを確認する
      expect(page).to have_content(@message_content)
    end
  end
  context 'コメントの新規投稿ができない' do
    it '投稿詳細ページでコメントを空のまま投稿すると保存できずに投稿詳細ページにリダイレクトする' do
      # ログインする
      sign_in(@user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # コメント入力フォームが表示されていることを確認する
      expect(page).to have_selector('textarea[name="comment[content]"]') 
      # 送信ボタンをクリックしてCommentモデルカウントが変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Comment.count}.by(0)
      # 投稿詳細ページにいることを確認する
      expect(current_path).to eq trip_path(@trip)
    end
    it 'ログアウト状態では投稿詳細ページにコメント入力フォームが表示されない' do
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # コメント入力フォームが表示されていないことを確認する
      expect(page).to have_no_selector('textarea[name="comment[content]"]') 
    end
  end
end

RSpec.describe "コメントの削除", type: :system do
  before do
    @comment = FactoryBot.create(:comment)
    @user = @comment.user
    @trip = @comment.trip
  end
  context 'コメントの削除ができる' do
    it 'コメントの投稿者本人はコメントを削除すると投稿詳細ページに戻る' do
      # ログインする
      sign_in(@user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 自分のコメントが表示されていることを確認する
      expect(page).to have_content(@comment.content)
      # 自分のコメントの削除ボタンが表示されていることを確認する
      expect(page).to have_selector('input[id="comment_delete_btn"]')
      # 削除ボタンをクリックするとCommentモデルカウントが1つ減少することを確認する
      expect(Comment.count).to eq 1
      find('input[id="comment_delete_btn"]').click
      sleep 3
      expect(Comment.count).to eq 0
      # 投稿詳細ページにいることを確認する
      expect(current_path).to eq trip_path(@trip)
      # 削除した投稿が表示されていないことを確認する
      expect(page).to have_no_content(@comment.content)
    end
  end
  context 'コメントの削除ができない' do
    it 'ログアウト状態ではコメントの削除ボタンが表示されない' do
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # コメントが表示されていることを確認する
      expect(page).to have_content(@comment.content)
      # コメントの削除ボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="comment_delete_btn"]')
    end
    it 'コメントの投稿者以外はコメントの削除ボタンが表示されない' do
      visiter = FactoryBot.create(:user)
      # コメント投稿者ではないユーザーがログインする
      sign_in(visiter)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # コメントが表示されていることを確認する
      expect(page).to have_content(@comment.content)
      # コメントの削除ボタンが表示されていないことを確認する
      expect(page).to have_no_selector('input[id="comment_delete_btn"]')
    end
  end
end