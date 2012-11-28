
html ->
  body ->
    js 'app'
    script src: '/box2d.js'
    script src: '/box2d.js'
    script src: '/socket.io/socket.io.js'
    script """
      var socket = io.connect('http://localhost:4000');
      socket.on('news', function (data) {
      console.log(data);
      socket.emit('my other event', { my: 'data' });
      });
    """