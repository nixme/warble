jQuery(document).ready ($) ->   
  window.draw_background = ->
    images = [
        'reyes.jpg'
        'brokeh.jpg'
        'universe.jpg'
        'pittsburgh.jpg'
        'goldengate.jpg'
      ]
  
      $.backstretch("/images/#{images[Math.floor(Math.random() * ((images.length - 1) - 0 + 1) + 0)]}", {speed: 150});
      true
   draw_background()