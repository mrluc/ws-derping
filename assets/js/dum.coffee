



socket = io.connect 'http://localhost:4000'
window.sock = socket

socket.on 'news', (data)->
  console.log data
  socket.emit 'from_client', my:'data'
