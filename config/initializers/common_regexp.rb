module CommonRegexp
  # 引数無しのmodule_functionにすると、
  # それ以降に定義したメソッドが全て
  # モジュールメソッドとして使えるようになる。
  module_function

  def format_email
    /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  end
  #module_function :format_email

  def format_unique_name
    /\A[a-z0-9_]+\z/i
  end
  #module_function :format_unique_name

  def extract_unique_name
    min = Settings.unique_name.length.minimum
    max = Settings.unique_name.length.maximum
    /@([0-9a-z_]{#{min},#{max}})/i
  end
  #module_function :extract_unique_name

end
