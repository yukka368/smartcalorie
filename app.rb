require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'pg'
require "pry"
require 'logger'
require 'json'
# require './src/web/ip002/SearchConditions' #他クラスをrequire（import）する際は./が必要

# logger = Logger.new('sinatra.log')
# SearchConditions = SearchConditions.new


enable :sessions



#DBにアクセスするファイル名を設定している
#smartcalorieデータベースを作成し、サインアップしたときにデータベースに記録されるように
client = PG::connect(
    :host => "localhost",
    :user => ENV.fetch("USER", "ayuka"), :password => 'ayuka1205',
    :dbname => "smartcalorie")




    get '/home' do
      return erb :home
    end



#サインアップ
get '/signup' do
     return erb :signup
end

post '/signup' do
    name = params[:name]
    email = params[:email]
    password = params[:password]
      #signupに入力されたデータをデータベースに保存している。赤文字はデータベース特有の文字列
    client.exec_params(
        "INSERT INTO users (name, email, password) VALUES ($1, $2, $3)",
        [name, email, password])
      #上で記録された情報をデータベースから抽出して配列（ハッシュ）として取り出している
    user = client.exec_params(
        "SELECT * from users WHERE email = $1 AND password = $2",
        [email, password]).to_a.first  
    session[:user] = user #39行目でuserに情報が代入されているためcookieを使用してユーザー自身であることを証明している
    return redirect '/mypage' #cookieとデータベースの違いというよりcookieがまだよくわかっていない気がする
end

get "/mypage" do
  @name = session[:user]['name'] 
    return erb :mypage
end





#サインイン
get '/signin' do
    return erb :signin
end

post '/signin' do
    email = params[:email]
    password = params[:password]
    user = client.exec_params(
      "SELECT * FROM users WHERE email = '#{email}' AND password = '#{password}'"
    ).to_a.first #ユーザー情報がなければnillを返すよ！
    if user.nil? #userにnilがついていればもう一度サインインしてみてと返す
        return erb :signin
    else
        session[:user] = user #ユーザー情報があるのならばDBからのデータを代入して42行目に飛ぶようにする
        return redirect '/mypage'
    end
end





#ログアウト
delete '/signout' do
  session[:user] = nil
  redirect '/signin'
end



get '/create_recipe' do
  @name = session[:user]['name'] #上の39行目で代入した情報のnameだけ取り出してインスタンス変数に代入しmypageで利用する
  return erb :create_recipe
end


#保存先
#criare_recipeに入力された情報をDBに保存する
post '/create_recipe'do

  dish=params[:dish]
  date=params[:date]
  categry=params[:categry]
  calorie=params[:food_num]
  content=params[:recipe]

  client.exec_params(
    "INSERT INTO recipes (dish, date, categry, calorie, content) VALUES ($1, $2, $3, $4, $5)",
    [dish, date, categry, calorie, content])

   
    return erb :create_recipe
end

post '' do  #文字に変更がある　このルーティンを使いたいときは直す/calculation_recip
  num = params[:num]
  name = params[:name]
  item = client.exec_params(
    "SELECT * FROM calories WHERE name = '#{name}'"
  ).to_a.first

  total = item["calorie"].to_i * num.to_i / 100
  name =  item["name"]
  @calorie = total
  @name = name
  # if !calorie.nil?
  #   return redirect '/layout'
  # end
  #item["calorie"]
  return erb :create_recipe
end
# 次何がしたい
# create_recipeにカロリーの数値を飛ばして計算する
# 必要なものカロリーの値
# ほんとは、同じ画面でデータベースから情報を取り出して表示
#


post '/calculation_recipe' do
  logger.info "/calculation_recipe"
  #検索用クラスのインスタンスを呼び出す。
  name = params[:name]
  num = params[:num]
  
  p name
  select_data = client.exec_params(
    "select * from calories where name='#{name}'"
  ).to_a.first
  p "select data"

  total = select_data["calorie"].to_i * num.to_i / 100
  p total
  name = select_data["name"]
  sikibetu = select_data["id"]

  content_type :json
  data = {"calories"=>total, "name"=>name, "sikibetu"=>sikibetu}
  p data.class
  p data.to_json.class
  data.to_json  #rubyで処理をして最終的にデータをjQureyへ返す
end


#データ型をストリングにすることでjQueryはデータを受け取れるようになりsuccessで処理が行われる。
#デバックのやり方
# rubyの場合pタグを使いコンソールにデータ型がどのような形
# となっているか確認する。.class(データ型の確認) .to_json(データ型の変更)

# jQureyの場合、console.log(引数)を使いコンソールで確認する
# もし、画面遷移する場合alertで強制的に止め引数でデータを表示させる

get '/myrecipe' do
  @name = session[:user]['name'] #上の39行目で代入した情報のnameだけ取り出してインスタンス変数に代入しmypageで利用する
  return erb :myrecipe
end