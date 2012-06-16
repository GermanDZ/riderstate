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
      pos = new google.maps.LatLng(0, 0);
      this.map = new google.maps.Map($('#map')[0], {
        zoom: 2,
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
      this.markerImage = new google.maps.MarkerImage('pin.png');
      this.markerImage.size = new google.maps.Size(32, 39);
      return this.markerImage.anchor = new google.maps.Point(6, 5);
    },
    show: function(hashesStr) {
      var code, hashes, latLng, showHash, _i, _len,
        _this = this;
      if (hashesStr) {
        hashes = hashesStr.split(" ");
        showHash = function(code) {
          var latLng, latLngBounds, pos1, pos2, rectangle;
          latLng = decodeGeoHash(code);
          pos1 = new google.maps.LatLng(latLng.latitude[0], latLng.longitude[0]);
          pos2 = new google.maps.LatLng(latLng.latitude[1], latLng.longitude[1]);
          latLngBounds = new google.maps.LatLngBounds(pos1, pos2);
          rectangle = new google.maps.Rectangle({
            map: _this.map,
            fillColor: '#FE904D',
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
        latLng = new google.maps.LatLng(latLng.latitude[2], latLng.longitude[2]);
        return new google.maps.Marker({
          position: latLng,
          animation: google.maps.Animation.DROP,
          icon: this.markerImage,
          map: this.map
        });
      }
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
