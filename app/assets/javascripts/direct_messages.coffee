# -----------------------------------------------------------------------------------------------------------------------------
# セレクタ定義
# -----------------------------------------------------------------------------------------------------------------------------
to_search_form_selector      = "#to_search_form"
user_selector                = "[data-user-id]"
trash_icon_selector          = "ul.messages .glyphicon-trash"
hide_dm_form_selector        = "#dm-hide-form"
dm_form_selector             = ".dm-input-form"
picture_icon_selector        = "#{dm_form_selector} .glyphicon-picture"
picture_form_selecotr        = "#{dm_form_selector} .picture"
preview_box_selector         = "#{dm_form_selector} .preview-box"
preview_remove_icon_selector = "#{dm_form_selector} .glyphicon-remove"

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

# ========================================================================
# DM一覧画面 画像プレビュー関連 begin
# ========================================================================
create_picture_element = (data_url) ->
  $("<img>").prop("src", data_url)

create_delete_icon = ->
  $("<span>").prop("class", "glyphicon glyphicon-remove")
             .prop("id", "preview_picture_delete")

preview_picture = (picture) ->
  reader = new FileReader()
  reader.readAsDataURL(picture)
  reader.addEventListener "loadend", (event) ->
    $(preview_box_selector).empty()
    $(preview_box_selector).append(create_picture_element(reader.result))
    $(preview_box_selector).append(create_delete_icon())
# ========================================================================
# DM一覧画面 画像プレビュー関連 end
# ========================================================================

# -----------------------------------------------------------------------------------------------------------------------------
# イベント定義
# -----------------------------------------------------------------------------------------------------------------------------
# $(document).onにする理由は、DOM操作等で追加した要素に対してイベント定義を
# 最初に読み込むjavascript内で定義する場合において、最初に定義される時点では
# その要素は存在しないためイベント定義ができない。そこで、最初から存在する
# $(document)に対してイベントを定義する。

# インクリメンタル検索
$(document).on 'keyup', to_search_form_selector, (event) ->
  url  = $(event.target).data('url')
  data = $.param({ query_word: $.trim($(this).val()) })
  ajax(url, "GET", data, false, false)
  return

# DMユーザ一覧画面およびDM宛先選択画面のインクリメンタル検索結果クリック時
$(document).on 'click', user_selector, (event) ->
  url  = $(event.currentTarget).data('url')
  page_title = $(event.currentTarget).data('page-title')
  data = $.param({ user_id: $(this).data('user-id'), page_title: page_title }) # params => user_id=1
  ajax(url, "GET", data)
  return

# ========================================================================
# DM一覧画面のゴミ箱アイコンクリック時 begin
# ========================================================================
$(document).on "click", trash_icon_selector, (event) ->
  swal(
    {text: "delete?", showCancelButton: true }
  ).then (result) ->
    if result.value
      # fire対象は、form要素を指定する。
      # $(hide_dm_form_selector)でformのjqueryオブジェクトを取得でき、
      # [0]でform要素が取得できる。
      Rails.fire($(hide_dm_form_selector)[0], "submit")

# hide_dm_form_selectorでsubmitされた結果がeventに入る。
# event.targetはhide_dm_form_selectorの要素を指す。
$(document).on "ajax:success", hide_dm_form_selector, (event) ->
  $(event.target.parentElement).remove()
  #event.target.parentElement.remove()  # →これだとIE11が対応していない。
  
# hide_dm_form_selectorでsubmitされたajaxの結果がeventに入る
$(document).on "ajax:error", hide_dm_form_selector, (event) ->
  console.log("hide_dm_form_error")
# ========================================================================
# DM一覧画面のゴミ箱アイコンクリック時 end
# ========================================================================

# DM一覧画面の画像選択アイコンクリック時
$(document).on "click", picture_icon_selector, (event) ->
  $(picture_form_selecotr).click()

# DM一覧画面の選択画像変化時
$(document).on "change", picture_form_selecotr, (event) ->
  if cmn_get_file_count(picture_form_selecotr) > 0
    picture = $(picture_form_selecotr).get(0).files[0]
    preview_picture(picture)

# DM一覧画面のプレビュー画像削除アイコンクリック時
$(document).on "click", preview_remove_icon_selector, (event) ->
  $(preview_box_selector).empty()
  $(picture_form_selecotr).val("")
