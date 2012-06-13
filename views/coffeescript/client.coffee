window.RiderState =
  run: ->
    _.bindAll this, 'initMap', 'show', 'import'
    google.maps.event.addDomListener(window, 'load', @initMap)
    window.rs = @

  initMap: ->
    pos = new google.maps.LatLng(40.52, -3.7)
    @map = new google.maps.Map $('#map')[0],
      zoom: 10
      center: pos
      navigationControl: false
      streetViewControl: false
      overviewMapControl: false
      scaleControl: false
      zoomControl: true
      zoomControlOptions:
        position: google.maps.ControlPosition.LEFT_CENTER
      draggable: true
      scrollwheel: false
      mapTypeControl: false
      mapTypeId: google.maps.MapTypeId.ROADMAP

  show: (hashesStr)->
    hashes = hashesStr.split(" ")
    showHash = (code) =>
      latLng = decodeGeoHash(code)
      pos1 = new google.maps.LatLng(latLng.latitude[0], latLng.longitude[0])
      pos2 = new google.maps.LatLng(latLng.latitude[1], latLng.longitude[1])
      latLngBounds = new google.maps.LatLngBounds(pos1, pos2)
      rectangle = new google.maps.Rectangle
        map: @map
        fillColor: '#4D90FE'
        fillOpacity: 0.5
        strokeColor: '#4D90FE'
        strokeOpacity: 0.5
      rectangle.setBounds(latLngBounds)
      # new google.maps.Marker
      #   position: new google.maps.LatLng(latLng.latitude[2], latLng.longitude[2])
      #   map: @map
    showHash code for code in hashes

  import: (id)->
    $.ajax
      url: 'import'
      data:
        id: id
        source: 'endomondo'
      success: (r)=> @show(r.response)
      dataType: 'JSON'