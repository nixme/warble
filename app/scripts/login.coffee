jQuery(document).ready ($) ->   
  images = [
      'reyes.jpg'
      'brokeh.jpg'
      'universe.png'
      'pittsburgh.png'
    ]
  
    $.backstretch("/images/#{images[(Math.floor(Math.random() * (images.length - 1 + 0)) + 0)]}", {speed: 150});
  