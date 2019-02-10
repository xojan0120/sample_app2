# -----------------------------------------------------------------------------------------------------------------------------
# 関数定義
# -----------------------------------------------------------------------------------------------------------------------------
# --------------------------------------
# インクリメンタル検索(非JSON版)
# --------------------------------------
# JSON版に比べてこちらのほうが、controllerから
# レンダリングするときにjs.slimを使うので
# rails側で色々処理ができて良さそう。
# --------------------------------------
ajax = (url, type, data, processData = true, contentType = true) ->
  $.ajax(
    url:         url
    type:        type
    data:        data
    processData: processData
    contentType: contentType
  )
  return

# # --------------------------------------
# # インクリメンタル検索(JSON版)
# # --------------------------------------
# # 検索クエリをXMLHttpRequestオブジェクトにする
# create_request = (query_url, query_word) ->
#   $.ajax(
#     url:          query_url
#     type:        "GET"
#     data:        "query_word=#{query_word}"
#     processData:  false
#     contentType:  false
#     dataType:    "json"
#   )
# 
# # jsonデータをul要素へ追加する
# append_list = (ul_element, json) ->
#   ul_element.find("li").remove()
#   $(json).each (i, user) ->
#     ul_element.append "<li>#{user.name} @#{user.unique_name}</li>"
#   return
# 
# # インクリメンタル検索
# incremental_search = (query_url, query_word, ul_element) ->
#   query = create_request(query_url, query_word)
#   query.done (json) -> append_list(ul_element, json)
#   return
# 
# # $(document).onにする理由は、DOM操作等で追加した要素に対してイベント定義を
# # 最初に読み込むjavascript内で定義する場合において、最初に定義される時点では
# # その要素は存在しないためイベント定義ができない。そこで、最初から存在する
# # $(document)に対してイベントを定義する。
# $(document).on 'keyup', '#to_search_form', (event) ->
#   incremental_search($(this).data('search-path'), $.trim($(this).val()), $("#result"))

# -----------------------------------------------------------------------------------------------------------------------------
# イベント定義
# -----------------------------------------------------------------------------------------------------------------------------
# $(document).onにする理由は、DOM操作等で追加した要素に対してイベント定義を
# 最初に読み込むjavascript内で定義する場合において、最初に定義される時点では
# その要素は存在しないためイベント定義ができない。そこで、最初から存在する
# $(document)に対してイベントを定義する。
$(document).on 'keyup', '#to_search_form', (event) ->
  url  = $(this).data('url')
  data = $.param({ query_word: $.trim($(this).val()) })
  ajax(url, "GET", data, false, false)
  return

# DM宛先選択画面のインクリメンタル検索結果クリック時
$(document).on 'click', '[data-user-id]', (event) ->
  url = $(this).data('url')
  data = $.param({ user_id: $(this).data('user-id') }) # params => user_id=1
  ajax(url, "GET", data)
  return

# DM一覧画面のゴミ箱アイコンクリック時
$(document).on 'click', '.glyphicon-trash', (event) ->
  swal({
    title: "delete?",
    showCancelButton: true
  }).then( (result) ->
    dm_id = $(event.target.parentElement).data('dm-id')
    console.log(dm_id)  # ここらへんから！！！
  )
