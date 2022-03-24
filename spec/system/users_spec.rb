require 'rails_helper'

  RSpec.describe "Users", type: :system do
    before do
      @user = FactoryBot.build(:user)
    end
    context 'ユーザー新規登録ができるとき' do
      it '正しい情報を入力すればユーザー新規登録ができてトップページに移動する' do
        # トップページに移動する
        visit root_path
        # トップページに新規登録ページへのリンクがあることを確認する
        expect(page).to have_link('新規登録', href: new_user_registration_path)
        # 新規登録ページに移動する
        visit new_user_registration_path
        # ユーザー情報を入力する
        fill_in 'user_email', with: @user.email
        fill_in 'user_name', with: @user.name
        fill_in 'user_password', with: @user.password
        fill_in 'user_password_confirmation', with: @user.password_confirmation
        # Sign upボタンを押すとユーザーモデルのカウントが１上がることを確認する
        expect{
          find('input[name="commit"]').click
        }.to change { User.count }.by(1)
        # トップページに遷移したことを確認する
        expect(current_path).to eq root_path
        # ログアウトページへのリンクが表示されていることを確認する
        expect(page).to have_link('ログアウト', href: destroy_user_session_path)
        # 新規登録したユーザー名でログイン中と表示されていることを確認する
        expect(page).to have_content("#{@user.name}でログイン中")
        # 新規登録やログインページへのリンクが表示されていないことを確認する
        expect(page).to have_no_link('新規登録', href: new_user_registration_path)
        expect(page).to have_no_link('ログイン', href: new_user_session_path)
      end
    end
    context 'ユーザー新規登録ができないとき' do
      it '誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる' do
        # トップページに移動する
        visit root_path
        # トップページに新規登録ページへのリンクがあることを確認する
        expect(page).to have_link('新規登録', href: new_user_registration_path)
        # 新規登録ページに移動する
        visit new_user_registration_path
        # ユーザー情報を入力する
        fill_in 'user_email', with: ''
        fill_in 'user_name', with: ''
        fill_in 'user_password', with: ''
        fill_in 'user_password_confirmation', with: ''
        # Sign upボタンを押してもユーザーモデルのカウントが上がらないことを確認する
        expect{
          find('input[name="commit"]').click
        }.to change { User.count }.by(0)
        # 新規登録ページに戻されることを確認する
        expect(current_path).to eq user_registration_path
        # エラーメッセージが表示されていることを確認する
        expect(page).to have_content("Email can't be blank")
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Password can't be blank")
      end
    end
  end

  RSpec.describe 'ログイン', type: :system do
    before do
      @user = FactoryBot.create(:user)
    end
    context 'ログインができるとき' do
      it '保存されているユーザーの情報と合致すればログインができる' do
        # トップページに移動する
        visit root_path
        # トップページにログインページへ遷移するボタンがあることを確認する
        expect(page).to have_content('ログイン')
        # ログインページへ遷移する
        visit new_user_session_path
        # 正しいユーザー情報を入力する
        fill_in 'user[email]', with: @user.email
        fill_in 'user[password]', with: @user.password
        # ログインボタンを押す
        find('input[name="commit"]').click
        # トップページへ遷移することを確認する
        expect(current_path).to eq root_path
        # ログアウトページへのリンクが表示されていることを確認する
        expect(page).to have_link('ログアウト', href: destroy_user_session_path)
        # 新規登録したユーザー名でログイン中と表示されていることを確認する
        expect(page).to have_content("#{@user.name}でログイン中")
        # 新規登録やログインページへのリンクが表示されていないことを確認する
        expect(page).to have_no_link('新規登録', href: new_user_registration_path)
        expect(page).to have_no_link('ログイン', href: new_user_session_path)
      end
    end
    context 'ログインができないとき' do
      it '保存されているユーザーの情報と合致しないとログインができない' do
        # トップページに移動する
        visit root_path
        # トップページにログインページへ遷移するボタンがあることを確認する
        expect(page).to have_content('ログイン')
        # ログインページへ遷移する
        visit new_user_session_path
        # ユーザー情報を入力する
        fill_in 'user[email]', with: 'nisemono@nisemono.com'
        fill_in 'user[password]', with: 'nisemono'
        # ログインボタンを押す
        find('input[name="commit"]').click
        # ログインページへ戻されることを確認する
        expect(current_path).to eq new_user_session_path
      end
    end
  end

RSpec.describe 'ユーザー情報編集', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end
  context '更新できるとき' do
    it '正しい情報を入力すると更新できる' do
      # トップページに移動する
      visit root_path
      # ログインする
      sign_in(@user)
      # 投稿履歴ページへ遷移するリンクが表示されていることを確認する
      expect(page).to have_link('投稿履歴', href: user_path(@user))
      # 投稿履歴ページへ遷移するリンクをクリックする
      click_on('投稿履歴')
      # 自分の投稿履歴ページに遷移したことを確認する
      expect(current_path).to eq user_path(@user)
      # 編集ボタンが表示されていることを確認する
      expect(page).to have_link('編集', href: edit_user_registration_path(@user))
      # 編集ボタンをクリックする
      click_on('編集')
      # 投稿編集ページに遷移したことを確認する
      expect(current_path).to eq edit_user_registration_path(@user)
      # 登録済みのメールアドレス、ユーザー名が入力済みであることを確認する
      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.introduce)
      # 新しいユーザー名と自己紹介を入力して送信する
      fill_in 'user[name]', with: 'new_name'
      fill_in 'user[introduce]', with: 'new_introduce'
      fill_in 'user[current_password]', with: @user.password
      # ユーザーモデルのカウントが増加しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {User.count}.by(0)
      # トップページに遷移したことを確認する
      expect(current_path).to eq root_path
      # 自分の投稿履歴ページに移動する
      visit user_path(@user)
      # 新しいユーザー名と自己紹介が表示されていることを確認する
      expect(page).to have_content('new_name')
      expect(page).to have_content('new_introduce')
    end
  end
  context '更新ができないとき' do
    it '書き換えた入力情報に不正な値があると更新できない' do
      # トップページに移動する
      visit root_path
      # ログインする
      sign_in(@user)
      # 投稿履歴ページへ遷移するリンクが表示されていることを確認する
      expect(page).to have_link('投稿履歴', href: user_path(@user))
      # 投稿履歴ページへ遷移するリンクをクリックする
      click_on('投稿履歴')
      # 自分の投稿履歴ページに遷移したことを確認する
      expect(current_path).to eq user_path(@user)
      # 編集ボタンが表示されていることを確認する
      expect(page).to have_link('編集', href: edit_user_registration_path(@user))
      # 編集ボタンをクリックする
      click_on('編集')
      # 投稿編集ページに遷移したことを確認する
      expect(current_path).to eq edit_user_registration_path(@user)
      # 登録済みのメールアドレス、ユーザー名が入力済みであることを確認する
      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.introduce)
      # 新しいユーザー名と自己紹介を入力して送信する
      fill_in 'user[name]', with: ''
      fill_in 'user[introduce]', with: 'new_introduce'
      fill_in 'user[current_password]', with: @user.password
      # ユーザーモデルのカウントが増加しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {User.count}.by(0)
      # 投稿編集ページにリダイレクトされていることを確認する
      expect(current_path).to eq user_registration_path
      # エラー文が表示されていることを確認する
      expect(page).to have_content("Name can't be blank")
    end
  end
end