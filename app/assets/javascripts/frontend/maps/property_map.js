import { Map } from './map.js'

class PropertyMap extends Map {

  constructor($map) {
    super($map);

    this.places = [];

    this.propertyLocation = {
      lng: this.$map.data('longitude'),
      lat: this.$map.data('latitude'),
    };

    this.streetViewCallback = this.streetViewCallback.bind(this);
    this.placesCheckboxCallback = this.placesCheckboxCallback.bind(this);
  }

  // Создает объект google карт
  createMap(center) {
    this.map = new google.maps.Map(
      this.$map[0],
      this.mapConfig(center)
    );
  }

  mapConfig(center) {
    let commonConfig = super.mapConfig();

    return {
      ...commonConfig,
      zoom: 15,
      center: center,
      scrollwheel: false,
    }
  }

  call() {

    // Чекбоксы выбирающие ближайшие магазины, школы и т.д.
    this.places = this.initializePlaces();
    this.createCheckBoxContainer(this.places);
    $('.places-checkbox').change(this.placesCheckboxCallback);

    // Создаем объект карты и отмечаем маркер недвижимости
    this.createMap(this.propertyLocation);
    this.createMarker(this.propertyLocation, this.propertyMarkerIcon());
    this.centerMarkers(this.map);

    // Добавляем кастомные кнопки зума
    this.zoomControl(this.map);

    // Устанавливаем коллбэки для режима просмотра улиц
    $('#streetView').on('click', this.streetViewCallback);
    let streetView = this.map.getStreetView();
    google.maps.event.addListener(streetView, 'visible_changed', function() {
      // Прячем кнопку вида просмотра улиц в этом режиме
      $('#streetView').toggle(!this.getVisible());
    });
  }

  // Формирует массив интересных мест для чекбокса
  // return [Object]
  initializePlaces() {
    let markersSt = [];
    let markersSc = [];
    let markersSW = [];

    i18next.changeLanguage(PROPIMO_LOCALE);

    return {
      'store' : {
        'type' : 'store',
          'color' : '#40bb8e',
          'name' : i18next.t('store'),
          'callback' : this.createCallBackByColor(markersSt, '#40bb8e'),
          'markers' : markersSt
      },
      'school' : {
        'type' : 'school',
        'color' : '#a97ebb',
        'name' : i18next.t('school'),
        'callback' : this.createCallBackByColor(markersSc, '#a97ebb'),
        'markers' : markersSc
      },
      'food' : {
        'type' : 'food',
        'color' : '#58e0e4',
        'name' : i18next.t('food'),
        'callback' : this.createCallBackByColor(markersSW, '#58e0e4'),
        'markers' : markersSW
      }
    }
  }

  // Метод конструирующий коллбэк для отрисовки определенных маркеров
  // @param [Array] array
  // @param [String] color
  // return [function]
  createCallBackByColor(array, color) {
    let that = this;

    return function callback(results, status) {
      if (status !== google.maps.places.PlacesServiceStatus.OK) { return; }

      _.each(results, (elem) => {
        array.push(that.createMarker(
          elem.geometry.location,
          that.createIconByColor(color, 0.5)
        ));
      });

      that.centerMarkers(that.map);
    }
  }

  // Элементы управления

  // Отрисовывает чекбоксы, которые фильтруют маркеры на карте
  // @param [Object] Хэш, соответствующий методу #initalizePlaces
  createCheckBoxContainer(places) {
    let container = document.getElementById('propertyMap-container');
    let div = document.createElement('div');
    div.className = "row";
    let divChecker = document.createElement('div');
    div.appendChild(divChecker);

    _.each(places, function (place) {
      divChecker = document.createElement('div');
      divChecker.className = "checkboxes one-in-row margin-bottom-10 places-checkbox col-md-3";

      let divI = document.createElement('div');
      divI.className = "col-md-1";

      let divCL = document.createElement('div');
      divCL.className = "col-md-2";

      let checkBox = document.createElement('input');
      checkBox.type = "checkbox";
      checkBox.name = place['type'];
      checkBox.id = "checkbox" + place['name'];

      let label = document.createElement('label');
      label.innerHTML = place['name'];
      label.setAttribute("for", "checkbox" + place['name']);

      let iElement = document.createElement('i');
      iElement.className = "fas fa-map-marker fa-2x";
      iElement.setAttribute("style", `color: ${place['color']};`);

      checkBox.value = "false";
      divCL.appendChild(checkBox);
      divCL.appendChild(label);
      divI.appendChild(iElement);
      divChecker.appendChild(divI);
      divChecker.appendChild(divCL);
      div.appendChild(divChecker);
    });

    container.appendChild(div)
  }

  // Коллбэки

  // Отрисовывает/убирает маркеры для соответствующих чекбоксов
  placesCheckboxCallback(e) {
    let checkbox = e.target;

    if (checkbox.checked) {
      let request = {
        location: {
          ...this.propertyLocation,
        },
        radius: '500',
        type: this.places[checkbox.name]['type']
      };

      let service = new google.maps.places.PlacesService(this.map);
      service.nearbySearch(request, this.places[checkbox.name]['callback']);

    } else {
      _.each(this.places[checkbox.name]['markers'], (marker) => {
        marker.setMap(null);

        this.allMarkers = this.allMarkers.filter((elem) => {
          return elem !== marker;
        });
      });

      this.centerMarkers(this.map);
    }
  }

  // Переход в режим просмотра улиц
  streetViewCallback(e) {
    e.preventDefault();

    let streetView = this.map.getStreetView();

    streetView.setOptions({
      visible: true,
      ...this.propertyLocation,
    });
  }
}

export {
  PropertyMap
}
