(function() {

  window.RiderState = {
    run: function() {
      var socket;
      _.bindAll(this, 'initMap', 'show', 'import');
      google.maps.event.addDomListener(window, 'load', this.initMap);
      socket = io.connect();
      return socket.on('workoutInfo', this.show);
    },
    initMap: function() {
      var pos;
      pos = new google.maps.LatLng(40.52, -3.7);
      return this.map = new google.maps.Map($('#map')[0], {
        zoom: 10,
        center: pos,
        navigationControl: false,
        streetViewControl: false,
        overviewMapControl: false,
        scaleControl: false,
        zoomControl: true,
        zoomControlOptions: {
          position: google.maps.ControlPosition.LEFT_CENTER
        },
        draggable: true,
        scrollwheel: false,
        mapTypeControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });
    },
    show: function(hashesStr) {
      var code, hashes, latLng, showHash, _i, _len,
        _this = this;
      hashes = hashesStr.split(" ");
      showHash = function(code) {
        var latLng, latLngBounds, pos1, pos2, rectangle;
        latLng = decodeGeoHash(code);
        pos1 = new google.maps.LatLng(latLng.latitude[0], latLng.longitude[0]);
        pos2 = new google.maps.LatLng(latLng.latitude[1], latLng.longitude[1]);
        latLngBounds = new google.maps.LatLngBounds(pos1, pos2);
        rectangle = new google.maps.Rectangle({
          map: _this.map,
          fillColor: '#4D90FE',
          fillOpacity: 0.5,
          strokeColor: '#4D90FE',
          strokeOpacity: 0.5
        });
        return rectangle.setBounds(latLngBounds);
      };
      for (_i = 0, _len = hashes.length; _i < _len; _i++) {
        code = hashes[_i];
        showHash(code);
      }
      latLng = decodeGeoHash(hashes[0]);
      this.map.setCenter(new google.maps.LatLng(latLng.latitude[0], latLng.longitude[0]));
      return this.map.setZoom(11);
    },
    "import": function(id) {
      var _this = this;
      return $.ajax({
        url: 'import',
        data: {
          id: id,
          source: 'endomondo'
        },
        success: function(r) {
          return _this.show(r.response);
        },
        dataType: 'JSON'
      });
    }
  };

}).call(this);
