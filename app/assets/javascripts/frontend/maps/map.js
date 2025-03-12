class Map {

  constructor($map) {
    this.$map = $map;
    this.map = null;

    // 1: мир
    // 5: континент
    // 10: Город
    // 15: Улицы
    // 20: Здания

    this.minZoom = 15;
    this.maxZoom = 2;
    this.zoomChanged = 1;

    this.allMarkers = [];

    this.request = true;
  }

  // MAP

  mapStyles() {
    return [
      {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#747474"},{"lightness":"23"}]},
      {"featureType":"poi.attraction","elementType":"geometry.fill","stylers":[{"color":"#f38eb0"}]},
      {"featureType":"poi.government","elementType":"geometry.fill","stylers":[{"color":"#ced7db"}]},
      {"featureType":"poi.medical","elementType":"geometry.fill","stylers":[{"color":"#ffa5a8"}]},
      {"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#c7e5c8"}]},
      {"featureType":"poi.place_of_worship","elementType":"geometry.fill","stylers":[{"color":"#d6cbc7"}]},
      {"featureType":"poi.school","elementType":"geometry.fill","stylers":[{"color":"#c4c9e8"}]},
      {"featureType":"poi.sports_complex","elementType":"geometry.fill","stylers":[{"color":"#b1eaf1"}]},
      {"featureType":"road","elementType":"geometry","stylers":[{"lightness":"100"}]},
      {"featureType":"road","elementType":"labels","stylers":[{"visibility":"off"},{"lightness":"100"}]},
      {"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#ffd4a5"}]},
      {"featureType":"road.arterial","elementType":"geometry.fill","stylers":[{"color":"#ffe9d2"}]},
      {"featureType":"road.local","elementType":"all","stylers":[{"visibility":"simplified"}]},
      {"featureType":"road.local","elementType":"geometry.fill","stylers":[{"weight":"3.00"}]},
      {"featureType":"road.local","elementType":"geometry.stroke","stylers":[{"weight":"0.30"}]},
      {"featureType":"road.local","elementType":"labels.text","stylers":[{"visibility":"on"}]},
      {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#747474"},{"lightness":"36"}]},
      {"featureType":"road.local","elementType":"labels.text.stroke","stylers":[{"color":"#e9e5dc"},{"lightness":"30"}]},
      {"featureType":"transit.line","elementType":"geometry","stylers":[{"visibility":"on"},{"lightness":"100"}]},
      {"featureType":"water","elementType":"all","stylers":[{"color":"#d2e7f7"}]}
    ];
  }

  mapConfig() {
    return {
      zoomControl: false,
      mapTypeControl: false,
      scaleControl: false,
      panControl: false,
      navigationControl: false,
      streetViewControl: false,
      styles: this.mapStyles()
    }
  }

  // MARKERS

  centerMarkers(map) {
    let bounds = new google.maps.LatLngBounds();

    _.each(this.allMarkers, (marker) => {
      bounds.extend(marker.getPosition());
    });

    let that = this;

    google.maps.event.addListener(map, 'zoom_changed', function() {
      let zoomChangeBoundsListener =
        google.maps.event.addListener(map, 'bounds_changed', function(event) {
          if(this.initialZoom === true) {

            if (this.getZoom() > that.minZoom) {
              // Change max/min zoom here
              this.setZoom(that.minZoom);
            }

            if (this.getZoom() < that.maxZoom) {
              // Change max/min zoom here
              this.setZoom(that.maxZoom);
            }

            this.initialZoom = false;
          }
          google.maps.event.removeListener(zoomChangeBoundsListener);
        });
    });

    map.initialZoom = true;
    map.fitBounds(bounds);
  }

  createMarker(position, icon, id=null) {
    let markerProps = {
      map: this.map,
      position: position,
      icon: icon
    };

    if(id !== null) {
     markerProps['id'] = id;
    }

    let marker = new google.maps.Marker(markerProps);
    this.allMarkers.push(marker);
    return marker;
  }

  createIconByColor(color, scale) {
    return {
      path: 'M19.9,0c-0.2,0-1.6,0-1.8,0C8.8,0.6,1.4,8.2,1.4,17.8c0,1.4,0.2,3.1,0.5,4.2c-0.1-0.1,0.5,1.9,0.8,2.6c0.4,1,0.7,2.1,1.2,3 c2,3.6,6.2,9.7,14.6,18.5c0.2,0.2,0.4,0.5,0.6,0.7c0,0,0,0,0,0c0,0,0,0,0,0c0.2-0.2,0.4-0.5,0.6-0.7c8.4-8.7,12.5-14.8,14.6-18.5 c0.5-0.9,0.9-2,1.3-3c0.3-0.7,0.9-2.6,0.8-2.5c0.3-1.1,0.5-2.7,0.5-4.1C36.7,8.4,29.3,0.6,19.9,0z M2.2,22.9 C2.2,22.9,2.2,22.9,2.2,22.9C2.2,22.9,2.2,22.9,2.2,22.9C2.2,22.9,3,25.2,2.2,22.9z M19.1,26.8c-5.2,0-9.4-4.2-9.4-9.4 s4.2-9.4,9.4-9.4c5.2,0,9.4,4.2,9.4,9.4S24.3,26.8,19.1,26.8z M36,22.9C35.2,25.2,36,22.9,36,22.9C36,22.9,36,22.9,36,22.9 C36,22.9,36,22.9,36,22.9z M13.8,17.3a5.3,5.3 0 1,0 10.6,0a5.3,5.3 0 1,0 -10.6,0',
      strokeOpacity: 0,
      strokeWeight: 1,
      fillColor: color,
      fillOpacity: 1,
      rotation: 0,
      scale: scale,
      anchor: new google.maps.Point(19,50)
    }
  }

  propertyMarkerIcon() {
    return this.createIconByColor('#274abb', 1)
  }

  // CONTROLS

  zoomControl(map) {
    let controlDiv = document.createElement('div');

    controlDiv.index = 1;
    map.controls[google.maps.ControlPosition.RIGHT_CENTER].push(controlDiv);
    // Creating divs & styles for custom zoom control
    controlDiv.style.padding = '5px';

    // Set CSS for the control wrapper
    let controlWrapper = document.createElement('div');
    controlDiv.appendChild(controlWrapper);

    // Set CSS for the zoomIn
    let zoomInButton = document.createElement('div');
    zoomInButton.className = "custom-zoom-in";
    controlWrapper.appendChild(zoomInButton);

    // Set CSS for the zoomOut
    let zoomOutButton = document.createElement('div');
    zoomOutButton.className = "custom-zoom-out";
    controlWrapper.appendChild(zoomOutButton);

    // Setup the click event listener - zoomIn
    google.maps.event.addDomListener(zoomInButton, 'click', () => {
      this.map.setZoom(this.map.getZoom() + 1);
      this.zoomChanged = 0;
    });

    // Setup the click event listener - zoomOut
    google.maps.event.addDomListener(zoomOutButton, 'click', () => {
      this.map.setZoom(this.map.getZoom() - 1);
      this.zoomChanged = 0;
    });
  }

}
export {
  Map
}
