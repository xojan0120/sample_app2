#if Rails.env.production?
#  CarrierWave.configure do |config|
#    config.fog_credentials = {
#      # Amazon S3用の設定
#      :provider              => 'AWS',
#      :region                => ENV['S3_REGION'],     # 例: 'ap-northeast-1'
#      :aws_access_key_id     => ENV['S3_ACCESS_KEY'],
#      :aws_secret_access_key => ENV['S3_SECRET_KEY'],
#      :path_style            => true               
#      # 最初↑がないとheroku環境で画像が表示されなかったが、なぜか一度このオプションを
#      # つけて、表示されるようなってから、また、これをはずしても表示されるようになった。謎。
#    }
#    config.fog_directory     =  ENV['S3_BUCKET']
#  end
#end

require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'
CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage :fog
    config.fog_provider = 'fog/aws'
    config.fog_directory  = ENV['S3_BUCKET']
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['S3_ACCESS_KEY'],
      aws_secret_access_key: ENV['S3_SECRET_KEY'],
      region: ENV['S3_REGION'],
      path_style: true
    }
  else
    config.storage :file
    config.enable_processing = false if Rails.env.test?
  end
end

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
