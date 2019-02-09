# ファイルフィールドで選択されたファイルサイズをチェックする
# サイズオーバーしていれば警告文をalertする。
@cmn_file_size_check = (selector, size_mb) ->
  $(selector).bind 'change', ->
    if @files[0] != undefined
      size_in_megabytes = @files[0].size / 1024 / 1024
      if size_in_megabytes > size_mb
        alert "Maximum file size is #{size_mb}MB. Please choose a smaller file."
      return
