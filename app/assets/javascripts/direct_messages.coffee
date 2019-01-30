# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# iziModalイベント登録(これでもいいけど、わかりにくい？)
#$ ->
#  $("[data-modal]").click (event) ->
#    event.preventDefault()
#    command = $(this).data('modal')
#    $('#modal').iziModal(command)

#$ ->
#  $("a[data-modal]").click (event) ->
#    event.preventDefault()
#    $('#modal').iziModal('open')
#
#$ ->
#  $("button[data-modal]").click (event) ->
#    event.preventDefault()
#    $('#modal').iziModal('close')

# --------------------------------------
# インクリメンタル検索用関数
# --------------------------------------
# 検索クエリをXMLHttpRequestオブジェクトにする
create_request = (query_url, query_word) ->
  $.ajax(
    url:          query_url
    type:        "GET"
    data:        "query_word=#{query_word}"
    processData:  false
    contentType:  false
    dataType:    "json"
  )

# jsonデータをul要素へ追加する
append_list = (ul_element, json) ->
  ul_element.find("li").remove()
  $(json).each (i, user) ->
    ul_element.append "<li>#{user.name} &lt;#{user.unique_name}&gt;</li>"
  return

# インクリメンタル検索
incremental_search = (query_url, query_word, ul_element) ->
  query = create_request(query_url, query_word)
  query.done (json) -> append_list(ul_element, json)
  return

# --------------------------------------
# インクリメンタル検索メイン
# --------------------------------------
# $(document).onにする理由は、DOM操作等で追加した要素に対してイベント定義を
# 最初に読み込むjavascript内で定義する場合において、最初に定義される時点では
# その要素は存在しないためイベント定義ができない。そこで、最初から存在する
# $(document)に対してイベントを定義する。
$(document).on 'keyup', '#to_search_form', (event) ->
  incremental_search($(this).data('search-path'), $.trim($(this).val()), $("#result"))
