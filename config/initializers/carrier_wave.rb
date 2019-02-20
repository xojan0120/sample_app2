if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Amazon S3用の設定
      :provider              => 'AWS',
      :region                => ENV['S3_REGION'],     # 例: 'ap-northeast-1'
      :aws_access_key_id     => ENV['S3_ACCESS_KEY'],
      :aws_secret_access_key => ENV['S3_SECRET_KEY']
      :path_style            => true               
      # 最初↑がないとheroku環境で画像が表示されなかったが、なぜか一度このオプションを
      # つけて、表示されるようなってから、また、これをはずしても表示されるようになった。謎。
    }
    config.fog_directory     =  ENV['S3_BUCKET']
  end
end
