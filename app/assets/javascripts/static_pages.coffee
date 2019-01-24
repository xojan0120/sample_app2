# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# iziModal初期化
$ ->
  $('#modal').iziModal({padding: 20})

# iziModalイベント登録(これでもいいけど、わかりにくい？)
#$ ->
#  $("[data-modal]").click (event) ->
#    event.preventDefault()
#    $('#modal').iziModal($(this).data('modal'))

$ ->
  $("a[data-modal]").click (event) ->
    event.preventDefault()
    $('#modal').iziModal('open')

$ ->
  $("button[data-modal]").click (event) ->
    event.preventDefault()
    $('#modal').iziModal('close')
