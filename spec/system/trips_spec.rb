require 'rails_helper'

RSpec.describe "Trip、Result新規投稿", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @trip_title = 'test title'
    @trip_content = 'test content'
    @trip_prefecture = Prefecture.all.find(id=10)
  end

  context 'Tripの新規投稿ができる' do
    it '子モデルのResultの新規作成はしないでTripのデータを入力すると投稿できて投稿詳細ページに遷移する' do
      # ログインする
      sign_in(@user)
      # 新規投稿ページへのリンクが存在することを確認する
      expect(page).to have_link('新規投稿', href: new_trip_path)
      # 新規投稿ページへのリンクをクリックする
      click_on('新規投稿')
      # 新規投稿ページに遷移したことを確認する
      expect(current_path).to eq new_trip_path
      # タイトル、内容、都道府県を入力する
      fill_in 'trip[title]', with: @trip_title
      fill_in 'trip[content]', with: @trip_content
      find("#trip_prefecture_id").find("option[value='10']").select_option
      # removeボタンを押して釣果フォームを削除する
      click_on('remove')
      # 釣果フォームが存在しないことを確認
      expect(page).to have_no_selector('input[name="trip[results_attributes][0][fish_name]"]')
      expect(page).to have_no_selector('input[name="trip[results_attributes][0][image]"]')
      # 送信ボタンをクリックしてTripモデルカウントが一つ増加し、Resultのモデルカウントは変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(1).and change {Result.count}.by(0)
      # 投稿詳細ページに遷移したことを確認する
      trip = @user.trips.first
      expect(current_path).to eq trip_path(trip)
      # 入力したタイトル、内容、都道府県、ユーザー名が表示されていることを確認する
      expect(page).to have_content(@trip_title)
      expect(page).to have_content(@trip_content)
      expect(page).to have_content(@trip_prefecture.name)
      expect(page).to have_content(@user.name)
    end
    it '複数の子モデルのResultのデータを入力してTripのデータを入力すると投稿できて投稿詳細ページに遷移する' do
      # ログインする
      sign_in(@user)
      # 新規投稿ページへのリンクが存在することを確認する
      expect(page).to have_link('新規投稿', href: new_trip_path)
      # 新規投稿ページへのリンクをクリックする
      click_on('新規投稿')
      # 新規投稿ページに遷移したことを確認する
      expect(current_path).to eq new_trip_path
      # Tripモデルのデータを入力する
      fill_in 'trip[title]', with: @trip_title
      fill_in 'trip[content]', with: @trip_content
      find("#trip_prefecture_id").find("option[value='10']").select_option
      # Resultモデルの一つ目のデータを入力する
      fill_in 'trip[results_attributes][0][fish_name]', with: 'イチバンサカナ'
      attach_file 'trip[results_attributes][0][image]', "#{Rails.root}/spec/system/images/test_image.png"
      # addボタンを押して釣果フォームを一つ追加する
      click_on('add')
      # 釣果フォームが2つ存在することを確認する
      expect(page.all('.result-fish_name-counter').count).to eq 2
      # タイトル、内容、都道府県、魚名、画像を入力する
      page.all('.result-fish_name-counter')[1].set('ニバンサカナ')
      # 送信ボタンをクリックしてTripモデルカウントが1つ、Resultモデルカウントが2つ増加したことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(1).and change {Result.count}.by(2)
      # 投稿詳細ページに遷移したことを確認する
      trip = @user.trips.first
      expect(current_path).to eq trip_path(trip)
      # 入力したタイトル、内容、都道府県、魚名、画像、ユーザー名が表示されていることを確認する
      expect(page).to have_content(trip.title)
      expect(page).to have_content(trip.content)
      expect(page).to have_content(trip.prefecture.name)
      expect(page).to have_content(trip.results.first.fish_name)
      expect(page).to have_content(trip.results.second.fish_name)
      expect(page).to have_selector("img[src$='.png']")
    end
  end
  context 'Tripの新規投稿ができない' do
    it 'Tripモデルのデータが正しく入力されないと投稿できない' do
      # ログインする
      sign_in(@user)
      # 新規投稿ページへのリンクが存在することを確認する
      expect(page).to have_link('新規投稿', href: new_trip_path)
      # 新規投稿ページへのリンクをクリックする
      click_on('新規投稿')
      # 新規投稿ページに遷移したことを確認する
      expect(current_path).to eq new_trip_path
      # Tripモデルの不適当なデータを入力する
      fill_in 'trip[title]', with: ''
      fill_in 'trip[content]', with: @trip_content
      find("#trip_prefecture_id").find("option[value='0']").select_option
      # Resultモデルの一つ目のデータを入力する
      fill_in 'trip[results_attributes][0][fish_name]', with: 'イチバンサカナ'
      attach_file 'trip[results_attributes][0][image]', "#{Rails.root}/spec/system/images/test_image.png"
      # 送信ボタンをクリックしてTripモデルカウントとResultモデルカウントが変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(0).and change {Result.count}.by(0)
      # 新規投稿ページにリダイレクトされたことを確認する
      expect(current_path).to eq trips_path
      # エラーメッセージが表示されていることを確認する
      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Prefecture can't be blank")
    end
    it 'Resultモデルのデータが正しく入力されないと投稿できない' do
      # ログインする
      sign_in(@user)
      # 新規投稿ページへのリンクが存在することを確認する
      expect(page).to have_link('新規投稿', href: new_trip_path)
      # 新規投稿ページへのリンクをクリックする
      click_on('新規投稿')
      # 新規投稿ページに遷移したことを確認する
      expect(current_path).to eq new_trip_path
      # Tripモデルのデータを入力する
      fill_in 'trip[title]', with: @trip_title
      fill_in 'trip[content]', with: @trip_content
      find("#trip_prefecture_id").find("option[value='10']").select_option
      # Resultモデルの不正なデータを入力する
      fill_in 'trip[results_attributes][0][fish_name]', with: 'ひらがなさかな'
      attach_file 'trip[results_attributes][0][image]', "#{Rails.root}/spec/system/images/test_image.png"
      # 送信ボタンをクリックしてTripモデルカウントとResultモデルカウントが変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(0).and change {Result.count}.by(0)
      # 新規投稿ページにリダイレクトされたことを確認する
      expect(current_path).to eq trips_path
      # エラーメッセージが表示されていることを確認する
      expect(page).to have_content("Results fish name is invalid. Use full-width katakana characters")
    end
    it 'ログインしていないと新規投稿できない' do
      # トップページに移動する
      visit root_path
      # 新規投稿ページへのリンクが表示されていないことを確認する
      expect(page).to have_no_link('新規投稿', href: new_trip_path)
    end
  end
end

RSpec.describe "Trip、Result編集", type: :system do
  before do
    @result = FactoryBot.create(:result)
    @trip = @result.trip
    @new_title = 'new title'
    @new_content = 'new content'
    @new_prefecture = Prefecture.all.find(id=46)
  end
  context '更新ができる場合' do
    it 'Tripモデルのデータのみ正しく変更すると成功して投稿詳細ページに遷移する' do
      # ログインする
      sign_in(@trip.user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 編集ボタンが表示されていることを確認する
      expect(page).to have_link('編集', href: edit_trip_path(@trip))
      # 編集ボタンをクリックする
      click_on('編集')
      # 自分の投稿の編集ページに遷移したことを確認する
      expect(current_path).to eq edit_trip_path(@trip)
      # タイトル、内容、都道府県に新しい値を入力
      fill_in 'trip[title]', with: @new_title
      fill_in 'trip[content]', with: @new_content
      find("#trip_prefecture_id").find("option[value='#{@new_prefecture.id}']").select_option
      # 送信ボタンをクリックしてTripとResultのモデルカウントが変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(0).and change {Result.count}.by(0)
      # 投稿詳細ページに遷移したことを確認する
      expect(current_path).to eq trip_path(@trip)
      # 新しく変更した値が表示されていることを確認する
      expect(page).to have_content(@new_title)
      expect(page).to have_content(@new_content)
      expect(page).to have_content(@new_prefecture.name)
    end
    it 'Resultモデルのデータのみ正しく変更すると更新されて投稿詳細ページに遷移する' do
      # ログインする
      sign_in(@trip.user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 編集ボタンが表示されていることを確認する
      expect(page).to have_link('編集', href: edit_trip_path(@trip))
      # 編集ボタンをクリックする
      click_on('編集')
      # 自分の投稿の編集ページに遷移したことを確認する
      expect(current_path).to eq edit_trip_path(@trip)
      # addボタンを押して釣果フォームを一つ追加する
      click_on('add')
      # 釣果フォームが1つ存在することを確認する
      expect(page.all('.result-fish_name-counter').count).to eq 1
      # タイトル、内容、都道府県、魚名を入力する
      page.all('.result-fish_name-counter')[0].set('アタラシイサカナ')
      # 送信ボタンをクリックしてResultモデルカウントが1つ減ってTripモデルカウントが変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(0).and change {Result.count}.by(1)
      # 投稿詳細ページに遷移したことを確認する
      expect(current_path).to eq trip_path(@trip)
      # 新しいresultのデータが表示されている
      expect(page).to have_content('アタラシイサカナ')
    end
    it 'Resultモデルの削除ボックスにチェックを入れて変更すると削除されて投稿詳細ページに遷移する' do
      # ログインする
      sign_in(@trip.user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 編集ボタンが表示されていることを確認する
      expect(page).to have_link('編集', href: edit_trip_path(@trip))
      # 編集ボタンをクリックする
      click_on('編集')
      # 自分の投稿の編集ページに遷移したことを確認する
      expect(current_path).to eq edit_trip_path(@trip)
      # 投稿済みの魚名が表示されていることを確認する
      expect(page).to have_content(@result.fish_name)
      # 削除ボタンが表示されていることを確認する
      expect(page).to have_selector('input[name="trip[results_attributes][1][_destroy]"]')
      # 削除ボタンにチェックを入れる
      find('input[name="trip[results_attributes][1][_destroy]"]').click
      # 送信ボタンをクリックしてResultモデルカウントが1つ減ってTripモデルカウントが変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(0).and change {Result.count}.by(-1)
      # 投稿詳細ページに遷移したことを確認する
      expect(current_path).to eq trip_path(@trip)
      # 削除したresultのデータが表示されていないことを確認する
      expect(page).to have_no_content(@result.fish_name)
    end
    it 'Tripモデルのデータを正しく変更してResultモデルの削除ボックスにチェックを入れて変更すると投稿詳細ページに遷移する' do
      # ログインする
      sign_in(@trip.user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 編集ボタンが表示されていることを確認する
      expect(page).to have_link('編集', href: edit_trip_path(@trip))
      # 編集ボタンをクリックする
      click_on('編集')
      # 自分の投稿の編集ページに遷移したことを確認する
      expect(current_path).to eq edit_trip_path(@trip)
      # タイトル、内容、都道府県に新しい値を入力
      fill_in 'trip[title]', with: @new_title
      fill_in 'trip[content]', with: @new_content
      find("#trip_prefecture_id").find("option[value='#{@new_prefecture.id}']").select_option
      # 投稿済みの魚名と画像が表示されていることを確認する
      expect(page).to have_content(@result.fish_name)
      expect(page).to have_selector("img[src$='.png']")
      # 削除ボタンが表示されていることを確認する
      expect(page).to have_selector('input[name="trip[results_attributes][1][_destroy]"]')
      # 削除ボタンにチェックを入れる
      find('input[name="trip[results_attributes][1][_destroy]"]').click
      # 送信ボタンをクリックしてResultモデルカウントが1つ減ってTripモデルカウントが変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(0).and change {Result.count}.by(-1)
      # 投稿詳細ページに遷移したことを確認する
      expect(current_path).to eq trip_path(@trip)
      # tripの新しいデータが表示されていて削除したresultのデータが表示されていないことを確認する
      expect(page).to have_content(@new_title)
      expect(page).to have_content(@new_content)
      expect(page).to have_content(@new_prefecture.name)
      expect(page).to have_no_content(@result.fish_name)
      expect(page).to have_no_selector("img[src$='.png']")
    end
  end
  context '更新ができない場合' do
    it 'Tripモデルの値に不正な値があるとResultモデルの削除もTripモデルの更新できず編集ページにリダイレクトされる' do
      # ログインする
      sign_in(@trip.user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 編集ボタンが表示されていることを確認する
      expect(page).to have_link('編集', href: edit_trip_path(@trip))
      # 編集ボタンをクリックする
      click_on('編集')
      # 自分の投稿の編集ページに遷移したことを確認する
      expect(current_path).to eq edit_trip_path(@trip)
      # 投稿済みの魚名が表示されていることを確認する
      expect(page).to have_content(@result.fish_name)
      # 削除ボタンが表示されていることを確認する
      expect(page).to have_selector('input[name="trip[results_attributes][1][_destroy]"]')
      # 削除ボタンにチェックを入れる
      find('input[name="trip[results_attributes][1][_destroy]"]').click
      # Tripモデルに不正な値を入力する
      fill_in 'trip[title]', with: ''
      fill_in 'trip[content]', with: ''
      find("#trip_prefecture_id").find("option[value='0']").select_option
      # 送信ボタンをクリックしてTripとResultのモデルカウントが変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(0).and change {Result.count}.by(0)
      # 編集ページにリダイレクトされていることを確認する
      expect(current_path).to eq trip_path(@trip)
      # エラーメッセージが表示されていることを確認する
      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Prefecture can't be blank")
    end
    it 'Resultモデルの値に不正な値があると更新できず編集ページにリダイレクトされる' do
      # ログインする
      sign_in(@trip.user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 編集ボタンが表示されていることを確認する
      expect(page).to have_link('編集', href: edit_trip_path(@trip))
      # 編集ボタンをクリックする
      click_on('編集')
      # 自分の投稿の編集ページに遷移したことを確認する
      expect(current_path).to eq edit_trip_path(@trip)
      # addボタンを押して釣果フォームを一つ追加する
      click_on('add')
      # 釣果フォームが1つ存在することを確認する
      expect(page.all('.result-fish_name-counter').count).to eq 1
      # タイトル、内容、都道府県、魚名、画像を入力する
      page.all('.result-fish_name-counter')[0].set('')
      # 送信ボタンをクリックしてTripとResultのモデルカウントが変化しないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {Trip.count}.by(0).and change {Result.count}.by(0)
      # 編集ページにリダイレクトされていることを確認する
      expect(current_path).to eq trip_path(@trip)
      # エラーメッセージが表示されていることを確認する
      expect(page).to have_content("Results fish name is invalid. Use full-width katakana characters")
    end
    it 'ログインしていないと投稿詳細ページに編集ボタンが表示されない' do
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 編集ボタンが表示されていないことを確認する
      expect(page).to have_no_link('編集', href: edit_trip_path(@trip))
    end
    it '投稿者本人以外のユーザーには投稿詳細ページに編集ボタンが表示されない' do
      visiter = FactoryBot.create(:user)
      # 第三者でログインする
      sign_in(visiter)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 編集ボタンが表示されていないことを確認する
      expect(page).to have_no_link('編集', href: edit_trip_path(@trip))
    end
  end
end

RSpec.describe "Trip削除", type: :system do
  before do
    @result = FactoryBot.create(:result)
    @trip = @result.trip
  end

  context '削除ができるとき' do
    it '投稿詳細ページで削除ボタンを押すと削除できてトップページに遷移する' do
      # ログインする
      sign_in(@trip.user)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 削除ボタンが表示されていることを確認する
      expect(page).to have_link('削除', href: trip_path(@trip))
      # 削除ボタンをクリックするとTripインスタンスとそれに紐づくResultインスタンスが削除されることを確認する
      expect{
        click_on('削除')
      }.to change {Trip.count}.by(-1).and change {Result.count}.by(-1)
      # トップページに遷移したことを確認する
      expect(current_path).to eq root_path
    end
  end
  context '削除ができないとき' do
    it 'ログインしていないと投稿詳細ページに削除ボタンが表示されない' do
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 削除ボタンが表示されていないことを確認する
      expect(page).to have_no_link('削除', href: trip_path(@trip))
    end
    it '投稿者本人以外のユーザーには投稿詳細ページに削除ボタンが表示されない' do
      visiter = FactoryBot.create(:user)
      # 第三者がログインする
      sign_in(visiter)
      # 投稿詳細ページに移動する
      visit trip_path(@trip)
      # 削除ボタンが表示されていないことを確認する
      expect(page).to have_no_link('削除', href: trip_path(@trip))
    end
  end
end