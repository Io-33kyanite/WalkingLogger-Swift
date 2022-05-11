# WalkingLogger-Swift
情報工学学生に向けた実験用iOSアプリ開発チュートリアルのためのGPS軌跡記録アプリ(GPSデータ取得・軌跡データ可視化・JSON永続化)。


# レクチャー内容

## イントロダクション
- この「研究・実験のためのiOSプログラミング入門」では，みんなで実験プログラムをひとつ作ってみる。
	- UI部品やコードの書き方などは網羅的にやらない。
		- 各々必要なタスクは違うので，自分のテーマが決まった後で，調べながら頑張ってください。
		- ただ，一度実験用プログラム作成のフローを知っておけば，ヒントになる？
- シチュエーション：5号館への入館を想定した歩行軌跡によるライフスタイル認証の検討
	- 理工学5号館では18時以降，入館に際して，セキュリティの観点から学生証によるカード認証を設けている。しかし，学生証を家に忘れたり，研究室においたまま間違って外に出てしまったりすることで，許可された学生にもかかわらず入館できなくなってしまう問題がある。そこで，スマートフォンに記録されたGPS軌跡ログのパターンを分析し人間情報工学コース学生かどうかを判定するアルゴリズムを開発し，学生証に代替する認証システムを実現する。
	- まずは，人間情報工学コース学生の歩行軌跡を収集して観察してみたい。
- 完成像をイメージする。
	- さすがに一日中密着して，歩行軌跡を調べるのは大変。iPhoneを使ってGPSデータを自動記録しよう。

## Chapter1: ユーザの現在地を地図に可視化してみよう。
- LoggingViewControllerの作成
- 地図を表示させる。
- 位置情報を取得する。
	- info.plistからプライバシー設定(Location When In Use Usage Discription)
		- ユーザのデータを利用するときは，許可を得なければいけない。
	- ロケーションマネージャ(CLLocationManager)を宣言。
	- setupLocationManager関数
  - requestWhenInUseAuthorization()
	  - Delegate: didChangeAuthorization
		  - Delegateメソッド：普通のメソッドみたいに逐次的に実行されるのではなく，イベントドリブンで実行できるようにする。
		- もしauthorizedWhenInUseならdelegateの設定と位置情報更新のスタートをかける。
	- Delegateメソッド: didUpdateLocations
		- デバッグエリアに表示してみる。
			- DebugからCity Runを選んでみる。
- 画面上に現在地を可視化する(ラベルと地図)。
	- 現在地に簡単にズームするために，zoomButton。

## Chapter2: ユーザの移動軌跡をリアルタイムで可視化してみよう。
- 開始と終了のインタフェース。
	- UI (recordingButton(figure.walk)とrecordingStatusLabel)を設置。
		- recordingStatusLabelを編集できないようにする。
	- RecordingStatus(pause or recording)をcurRecordingStatusに保持。
	- recordingButtonを押した時の処理
		- curRecordingStatusで分ける。
		- アクションシートで記録を開始/停止するかユーザに尋ねる。
- 開始処理
	- どこに位置情報を保管するか。変数locationList(CLLocationCoordinate2Dの配列)をグローバル定義。
	- curLocationはセンサが値を取得するごとに更新されるが，「一定時間ごと」をどうやって知るか。
		- 3秒ごとにhandleRecordingTimer()を発火するタイマーを用意。
- 閑話休題：あとは何が必要？？
	- TODO: 地図に可視化してみよう
	- TODO: 何らかの形でデータを保存してみよう
	- ここまでできたら実験用アプリとして役立ちそう！！
- 地図上への可視化。
	- 前回の位置データと今回の位置データを用意して，配列coordinatesに格納。
	- MKPolylineを用意。
	- baseMapにaddOverlay
	- 描画時，デザイン等を設定しなければ描画されない。したがってデリゲートメソッドを記述する。
		- MKMapViewDelegateプロトコルを追加。
		- mapView(_:MKMapView, rendererFor:MKOverlay)関数を用意。
			- MKPolylineRendererにMKPolylineをセット。
			- strokeColorとlineWidthを設定。
	- 停止時に描画された軌跡もリセットされるようにしたい。

## Chapter3: ユーザの移動軌跡ログを保存してみよう。
- イントロダクション：データの永続化
	- 汎用性の高いJSONファイル形式を採用して軌跡データを永続化してみよう。(PythonやJavascriptで簡単に読み込める)。
	- 辞書型なので柔軟性が高く，後から見てわかりやすい。
	- Swift上でも扱いやすい(plistでもいいがJSONの方がメジャーかつシンプル)
- JSONで永続化してみる。
	- 構造体を使って 軌跡データTrajectoryのデータモデルを定義。
		- Trajectory.swiftの作成。
		- 軌跡データ(一定時間毎に取得される現在地の配列)を入れるのはlocationList。メタデータとしてcreatedAt, age, device, description。
		- LocationDataの中身を別で作成。 latitude, longitude, timestamp
	- タイムスタンプを発行する関数を作る。
		- Tools.swiftの作成。
		- タイムスタンプフォーマットの設計。
			- ISO8601を検討。
			- ファイル名をユニークにするため，タイムスタンプを用いる。
				- しかしコロンは適さない。
				- ダッシュとコロンを除いた基本形「yyyyMMddTHHmmssZ (e.g., 20220413T114559Z)」を採用。  
			- Tools.getStringTimestamp()の作成。
				- static修飾子をつけてタイプメソッドとして扱う。
	- Trajectory構造体のイニシャライザを記述。
		- age, device, descriptionについては割愛。
	- LoggingViewControllerを書き換えて，Trajectoryデータモデルに合わせる。
		- 前回はプロパティtrajectoryをCLLocationCoordinate2Dの配列として宣言していたが，JSONでの書き出しを実装するためにさきほど作ったTrajectory構造体を宣言する。
		- 当然ながら，それに伴っていくつかのエラーが発生するので，これを修正していく。
	- JSONへエンコード
		- データモデルを記述した構造体がCodableプロトコルに適合しているかチェック。
		- Trajectory構造体にコンピューテッドプロパティjsonを記述。
	- 保存先(Documentsフォルダ)を指定して保存する。
		- let documentsPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		- jsonData.write(to: filePath)
- 保存したファイルを取り出すには？
	- (iPhoneを持っていないヒト)シミュレータから取り出す。
		- ただちょっとややこしい。シミュレータやアプリケーションにユニークなIDが振られているため，見つけるのが困難。
		- open_latest_app.shを使って開いてもらう。
			- 最近でインストールしたシミュレータデバイスのアプリサンドボックスがよばれる。
			- フォルダを更新日時順に並べて最も新しいものを選択して開くという力技プログラム。
	- 王道。実機でやったパターン。パソコンに繋いでXcodeからパッケージをダウンロード。
		- Documentsフォルダを見ると…！

