window.RiderState =
  run: ->
    _.bindAll this, 'initMap', 'show', 'import'
    google.maps.event.addDomListener(window, 'load', @initMap)
    socket = io.connect()
    socket.on 'workoutInfo', @show

  initMap: ->
    pos = new google.maps.LatLng(0, 0)
    @map = new google.maps.Map $('#map')[0],
      zoom: 2
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
    @markerImage = new google.maps.MarkerImage('pin.png')
    @markerImage.size = new google.maps.Size(32, 39)
    @markerImage.anchor = new google.maps.Point(6, 5)

  show: (hashesStr)->
    if hashesStr
        hashes = hashesStr.split(" ")
        showHash = (code) =>
          latLng = decodeGeoHash(code)
          pos1 = new google.maps.LatLng(latLng.latitude[0], latLng.longitude[0])
          pos2 = new google.maps.LatLng(latLng.latitude[1], latLng.longitude[1])
          latLngBounds = new google.maps.LatLngBounds(pos1, pos2)
          rectangle = new google.maps.Rectangle
            map: @map
            fillColor: '#FE904D'
            fillOpacity: 0.5
            strokeColor: '#4D90FE'
            strokeOpacity: 0.5
          rectangle.setBounds(latLngBounds)
        showHash code for code in hashes
        latLng = decodeGeoHash(hashes[0])
        latLng = new google.maps.LatLng(latLng.latitude[2], latLng.longitude[2])
        new google.maps.Marker
           position: latLng
           animation: google.maps.Animation.DROP
           icon: @markerImage
           map: @map

  import: (id)->
    $.ajax
      url: 'import'
      data:
        id: id
        source: 'endomondo'
      success: (r)=> @show(r.response)
      dataType: 'JSON'