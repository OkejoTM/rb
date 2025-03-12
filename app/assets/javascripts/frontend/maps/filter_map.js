const InfoBox = require("exports-loader?InfoBox!findeo/scripts/infobox.min.js");
const MarkerClusterer = require("exports-loader?MarkerClusterer!findeo/scripts/markerclusterer.js");
import { Map } from './map'
import { deviceMobile } from "../utils";

class FilterMap extends Map {

  constructor($map) {
    super($map);

    this.zoomLevel = this.maxZoom;
    this.mapScrollAttr = $map.attr('data-map-scroll');
    this.mapZoomAttr = $map.attr('data-map-zoom');

    this.boundsMap = {
      lngNE: 0,   //долгота Северо-Восток (x правый верхний угол)
      latNE: 0,   //широта Северо-Восток  (y правый верхний угол)
      lngSW: 0,   //долгота Юго-Запад     (x левый нижний угол)
      latSW: 0    //широта Юго-Запад      (y левый нижний угол)
    };

    this.loadMap = false;    // Карта уже загружена
    this.ajaxReq = null;     // Сам запрос, чтоб его прервать
    this.result = null;

    // Список мест(локаций)
    this.locations = [];

    // Список недвижимости
    this.properties = [];

    this.currentInfobox = null;
    this.boxText = null;
    this.markerCluster = null;


    this.findBtnCallback = this.findBtnCallback.bind(this);
    this.boundsCallback = this.boundsCallback.bind(this);
    this.scrollCallback = this.scrollCallback.bind(this);
    this.geolocateCallback = this.geolocateCallback.bind(this);
    this.showMapClickCallback = this.showMapClickCallback.bind(this);
    this.closeMapClickCallback = this.closeMapClickCallback.bind(this);
    this.nextPropertyCallback = this.nextPropertyCallback.bind(this);
    this.prevPropertyCallback = this.prevPropertyCallback.bind(this);
    this.loadProperties = this.loadProperties.bind(this);
    this.resizeModalCallback = this.resizeModalCallback.bind(this);
  }

  createMap(zoomLevel, scrollEnabled, mapLatitude, mapLongitude) {
    // Создание карты
    this.map = new google.maps.Map(
      this.$map[0],
      this.mapConfig(zoomLevel, scrollEnabled, mapLatitude, mapLongitude)
    );
  }

  mapConfig(zoomLevel, scrollEnabled, mapLatitude, mapLongitude) {
    let commonConfig = super.mapConfig();

    return {
      ...commonConfig,
      zoom: zoomLevel,
      scrollwheel: scrollEnabled,
      center: new google.maps.LatLng(mapLatitude, mapLongitude),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      gestureHandling: 'cooperative',
      fullscreenControl: true,
      fullscreenControlOptions: {
        position: google.maps.ControlPosition.RIGHT_TOP     //Помещаем фуллскрин в правый верхний угол
      }
    }
  }

  infoBoxConfig() {
    return {
      content: this.boxText,
      disableAutoPan: true,
      alignBottom : true,
      maxWidth: 0,
      pixelOffset: new google.maps.Size(-60, -55),
      zIndex: null,
      boxStyle: {
        width: "260px"
      },
      closeBoxMargin: "0",
      closeBoxURL: "",
      infoBoxClearance: new google.maps.Size(1, 1),
      isHidden: false,
      pane: "floatPane",
      enableEventPropagation: false,
    };
  }

  //Опции для кластеров на карте
  clusterConfig() {
    return [{
      textColor: 'white',
      url: '',
      height: 50,
      width: 50
    }];
  }

  //Обновляет грани карты
  updateBounds() {
    let bounds = {
      lngNE: 0,
      latNE: 0,
      lngSW: 0,
      latSW: 0
    };

    if (this.map != null && this.map.getBounds() != null) {
      let northEast = this.map.getBounds().getNorthEast();
      let southWest = this.map.getBounds().getSouthWest();

      bounds = {
        lngNE: northEast.lng(),
        latNE: northEast.lat(),
        lngSW: southWest.lng(),
        latSW: southWest.lat()
      };
    }

    this.boundsMap = bounds;
  }

  //Добавляет callback по изменению граней карты
  addCallBackForBounds() {
    this.map.addListener('bounds_changed', this.boundsCallback);
  }

  cleanAllMap() {
    if (this.markerCluster != null) {
      this.markerCluster.clearMarkers();
    }

    _.each(this.allMarkers, function (marker) {
      marker.setMap(null);
    });

    this.allMarkers.length = 0;
    this.properties = [];
    this.locations = [];
  }

  createAllMarkers() {
    //Для всей полученной недвижимости создаем места
    _.each(this.properties, (property) => {
      if (_.isNil(property.latitude)) { return; }

      this.locations.push([
        property.id,
        property.latitude,
        property.longitude,
        1,
        this.propertyMarkerIcon()
      ])
    });

    //Для всех мест создаем маркеры и информационные сообщения
    let i = 0;
    _.each(this.locations, (location) => {
      let position = new google.maps.LatLng(location[1], location[2]);
      let marker = this.createMarker(position, location[4], i++);

      let ib = new InfoBox();

      google.maps.event.addListener(
        marker,
        'click',
        this.markerCallback(marker, ib, location[0], location[1], location[2])
      );
    });
  }

  //Выставляет карту по центру
  updateLoaderPosition() {
    //Прелоад карты ставим по центру
    setInterval(function() {
      let $map = $('#map');
      let $map_load = $('#map_load');

      let mapLeft = $map.position().left;
      let mapTop = $map.position().top;

      if (mapLeft > 0 && mapTop > 0) {
        $map_load.css('left', mapLeft + $map.width() * 0.5);
        $map_load.css('top', mapTop + $map.height() * 0.5);
      }
    }, 100);
  }

  //Делает карту видимой
  enableMap() {
    $('.modal-body').css('opacity', 1);
    $('#map_load').css('display', 'none');
  }

  //Делает карту невидимой
  disableMap() {
    $('.modal-body').css('opacity', 0.3);
    this.updateLoaderPosition();
    $('#map_load').css('display', 'block');
  }

  loadProperties() {
    //Собираем параметры запроса
    let req_props = $('#properties_form').serializeArray();

    //Добавляем к запросу грани
    req_props.push({
      name: "bounds",
      value: JSON.stringify(this.boundsMap)
    });

    //Отправляем новый запрос
    this.request = false;

    this.ajaxReq = $.ajax({
      method: "GET",
      url: `/${PROPIMO_LOCALE}/properties_for_map`,
      data: req_props,
      dataType: "json"
    }).done((data) => {
      //Чистим карту
      this.cleanAllMap();
      //Парсим полученный результат
      this.result = jQuery.parseJSON(JSON.stringify(data));
      this.properties = this.result['properties'];

      this.createAllMarkers();

      //Создаем кластер
      this.markerCluster = new MarkerClusterer(
        this.map,
        this.allMarkers,
        {
          imagePath: 'images/',
          styles : this.clusterConfig(),
          minClusterSize : 2
        }
      );

      //Если карта загружена впервые, то центрируем ее и добавляем на нее callback
      if (!this.loadMap) {
        this.centerMarkers(this.map);
        $.when(
          this.addCallBackForBounds()
        ).done(this.loadMap = true);
      }
      //Запрос считаем выполненным
      this.request = true;

      //Включаем карту
      this.enableMap();
      this.ajaxReq = null;
    }).fail((error) => {
      console.error("Error!!! Something in GET /properties_for_map was wrong. Can't do because: " + error);
    })
  }

  //Находим недвижимость
  findProperties() {
    // setTimeout для избежания двойных кликов и тд
    // Если предыдущий запрос уже выполнен
    if (this.request) {
      // Делаем карту недоступной, если она грузится в первый
      if(this.loadMap) {
        // Уточняем грани карты для запроса
        this.updateBounds();
      } else {
        this.disableMap();
      }

      setTimeout(this.loadProperties, 1000);
    }
  }

  // убирает из строки статус карты
  updateMapStatus(data, mapStatus) {
    let resultData = data.replace("&map=on", "").replace("?map=on", "");

    if (mapStatus === "") {
      return resultData;
    }

    if (resultData.indexOf("?") !== -1) {
      return resultData + "&" + mapStatus
    } else {
      return resultData + "?" + mapStatus
    }
  }

  getMapStatus() {
    let $modal = $('.modal-map');

    if($modal.css('display') === "block") {
      return "map=on";
    }
    return "";
  }

  changeHistory(data, mapStatus=this.getMapStatus()){
    let params = this.updateMapStatus(data, mapStatus);
    if (params === ""){
      window.history.replaceState({}, "", window.location.pathname);
    } else {
      window.history.replaceState({}, "", this.updateMapStatus(data, mapStatus));
    }

  }

  call() {

    // Нажатие кнопки фильтра
    $('#find_btn').click(this.findBtnCallback);


    // Если еще не задан зум карты, то задаем его
    if (!_.isUndefined(this.mapZoomAttr) && this.mapZoomAttr !== false) {
      this.zoomLevel = parseInt(this.mapZoomAttr);
    }

    let scrollEnabled = false;

    // Если еще не задано смещение карты, то задаем его
    if(!_.isUndefined(this.mapScrollAttr) && this.mapScrollAttr !== false) {
      scrollEnabled = parseInt(this.mapScrollAttr);
    }

    let $lat = $('#area_latitude');
    let $long = $('#area_longitude');
    let mapLatitude = null;
    let mapLongitude = null;

    if($lat.length > 0 && $long.length > 0) {
      mapLatitude = $lat.val();
      mapLongitude = $long.val();
    }

    // Если еще не заданы широта и долгота ...
    if(_.isNil(mapLatitude) || mapLatitude === '' || _.isNil(mapLatitude) || mapLongitude === '') {
      // По умолчанию прыгаем в Канзас
      mapLatitude = 38;
      mapLongitude = -98;
    }

    this.createMap(
      this.zoomLevel,
      scrollEnabled,
      mapLatitude,
      mapLongitude
    );

    this.renderCloseBtn();
    this.renderEnableScroll();

    this.renderInfoText();

    this.renderZoomControls();

    // Локация относительно текущего местоположения пользователя
    $("#geoLocation").click(this.geolocateCallback);

    let $showMap = $('#show_map');
    //Кнопка открытия карты
    $showMap.click(this.showMapClickCallback);

    if (window.location.search.indexOf("map=on") !== -1 || $showMap.attr('data-map-open') === 'true') {
      $showMap.click();
    }

    // Следующая недвижимость
    $('#nextpoint').click(this.nextPropertyCallback);

    //Предыдущая недвижимость
    $('#prevpoint').click(this.prevPropertyCallback);

    /* Half Map Adjustments */
    $(window).on('load resize', this.resizeModalCallback); //brakes on phones

    if(!deviceMobile()) {
      this.resizeModalCallback();
    } else {
      // $('.modal-dialog.modal-map-dialog.modal-lg').css({margin: 'auto', height: '100%', width: '100%'});
      // $('.modal-body.modal-map-body').css({padding: 0});
      // $('.modal.modal-map.in').css({top: 0, right: 0, left: 0});
    }
  }

  // Элементы управления

  renderCloseBtn() {
    if(!deviceMobile()) { return; }

    let closeBtnHtml =
      '<div id="close-map">' +
      '  <button type="button"' +
      '          class="close"' +
      '          data-dismiss="modal"' +
      '          aria-label="Close"' +
      '          style="width:100%; height:100%;"' +
      '  >' +
      '    <span aria-hidden="true">&times;</span>' +
      '  </button>' +
      '</div>';
    let $closeBtn = $(closeBtnHtml);

    let controlDiv = $closeBtn[0];
    controlDiv.index = 1;

    // Помещаем кнопочку в правый верхний угол
    // https://google-developers.appspot.com/maps/documentation/javascript/examples/full/control-positioning-labels
    this.map.controls[google.maps.ControlPosition.TOP_RIGHT].push(controlDiv);

    //Закрытие карты
    $closeBtn.click(this.closeMapClickCallback);
  }

  renderEnableScroll() {
    let scrollHtml =
      '<a href="#"' +
      '   id="scrollEnabling"' +
      '   title="Enable or disable scrolling on map"' +
      '   class="margin-top-10 margin-left-10"' +
      '   style="display: none;"' +
      '>' +
      '  Enable Scrolling' +
      '</a>';

    let $scroll = $(scrollHtml);
    $scroll.show();

    let controlDiv = $scroll[0];
    controlDiv.index = 1;

    // Помещаем кнопочку в левый верхний угол
    // https://google-developers.appspot.com/maps/documentation/javascript/examples/full/control-positioning-labels
    this.map.controls[google.maps.ControlPosition.TOP_LEFT].push(controlDiv);

    // Scroll краты
    $scroll.click(this.scrollCallback);

  }

  renderZoomControls() {

    // Custom zoom buttons
    this.zoomControl(this.map);

    google.maps.event.addDomListener(window, "resize", () => {
      let center = this.map.getCenter();
      google.maps.event.trigger(this.map, "resize");
      this.map.setCenter(center);
    });
  }

  propertyTemplate(locationURL, locationPrice, locationPriceDetails, locationImg, locationTitle, locationAddress) {
    return(
      `<a href="${locationURL}" class="listing-img-container">` +
      '<div class="infoBox-close"><i class="fas fa-times"></i></div>' +
      '<div class="listing-img-content">' +
      `<span class="listing-price">${locationPrice}<i>${locationPriceDetails}</i></span>` +
      '</div>' +
      `<img src="${locationImg}" alt="">` +
      '</a>' +
      '<div class="listing-content">' +
      '<div class="listing-title">' +
      `<h4><a href="#">${locationTitle}</a></h4><p>${locationAddress}</p>` +
      '</div>' +
      '</div>'
    )
  }

  renderInfoText() {
    this.boxText = document.createElement("div");
    this.boxText.className = 'map-box';
  }

  // Коллбэки

  findBtnCallback(e) {
    $('#page').val(0);

    this.loadMap = false;

    // Находим недвижимость по критериям
    this.findProperties();
  }

  boundsCallback() {
    //Если карта загружена, то находим новую недвижимость
    if (this.loadMap && this.zoomChanged === 0) {
      this.findProperties();
    }
  }

  markerCallback(marker, info_box, property_id, latitude, longitude) {
    let that = this;

    return function() {
      $.ajax({
        method: "GET",
        url: `/${PROPIMO_LOCALE}/property_for_map`,
        data: { id: property_id, currency: $('#currency').val() },
        dataType: "json",
        error: function (jqXHR, error) {
          console.error("Error!!! Something in GET /property_for_map was wrong. Can't do because: " + error);
        },
        success: function (data) {
          info_box.setOptions(that.infoBoxConfig());
          that.boxText.innerHTML = that.propertyTemplate(
            data.seo_path, //'single-property-page-1.html'
            data.format_price, //'$275,000'
            data.format_price_for_area, //'$520 / sq ft'
            data.main_picture, //'images/listing-01.jpg'
            data.short_page_title, //'Eagle Apartmets'
            data.address //"9364 School St. Lynchburg, NY "
          );
          info_box.open(that.map, marker);
          that.currentInfobox = marker.id;
          let latLng = new google.maps.LatLng(latitude, longitude);
          that.map.panTo(latLng);
          that.map.panBy(0, -180);

          google.maps.event.addListener(info_box, 'domready', function () {
            $('.infoBox-close').click(function (e) {
              e.preventDefault();
              info_box.close();
            });
          });
        }
      });
    }
  }

  //По текущей позиции клиента
  geolocateCallback(e) {
    e.preventDefault();

    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition((position) => {
        let pos = new google.maps.LatLng(
          position.coords.latitude,
          position.coords.longitude
        );
        this.map.setCenter(pos);
        this.map.setZoom(12);
      });
    }
  }

  scrollCallback(e) {
    e.preventDefault();
    let $scrollEnabling = $('#scrollEnabling');
    $scrollEnabling.toggleClass("enabled");

    if($scrollEnabling.is(".enabled")) {
      this.map.setOptions({'scrollwheel': true});
    } else {
      this.map.setOptions({'scrollwheel': false});
    }
  }

  showMapClickCallback(e) {
    google.maps.event.trigger(this.map, 'resize');
    //Меняем параметр в истории
    this.changeHistory(window.location.search, "map=on");
    this.findProperties();
  }

  closeMapClickCallback(e) {
    if(this.ajaxReq && this.ajaxReq.readyState !== 4) {
      this.ajaxReq.abort();
      this.ajaxReq = null;
      this.request = true;
    }
    //Меняем параметр в истории
    this.changeHistory(window.location.search, "");
    //Считаем что карта не загружена
    $('.grid').trigger('click')
  }

  nextPropertyCallback(e) {
    e.preventDefault();

    this.map.setZoom(15);

    let index = this.currentInfobox;
    let markerIndex = 0;

    if (index + 1 < this.allMarkers.length ) {
      markerIndex = index + 1;
    }

    google.maps.event.trigger(this.allMarkers[markerIndex],'click');
  }

  prevPropertyCallback(e) {
    e.preventDefault();

    this.map.setZoom(15);
    let markerIndex = null;

    if (_.isUndefined(this.currentInfobox)) {
      markerIndex = this.allMarkers[this.allMarkers.length - 1];
    } else {
      let index = this.currentInfobox;
      if(index - 1 < 0) {
        //if index is less than zero than open last marker from array
        markerIndex = this.allMarkers[this.allMarkers.length - 1];
      } else {
        markerIndex = index - 1;
      }
    }
    google.maps.event.trigger(markerIndex,'click');
  }

  resizeModalCallback() {

    let topbarHeight = $("#top-bar").height();
    let headerHeight = $("#header").innerHeight() + topbarHeight;

    $(".fs-container").css('height', `${$(window).height() - headerHeight}px`);

    //Если есть модальное окно карты...
    let $modalMap = $('.modal-map');

    if ($modalMap.length > 0) {
      //Выравниваем его позицию
      let position = $('#property-body').position();

      $modalMap.css('left', position.left);
      $modalMap.css('top', position.top * 0.95);

      this.updateLoaderPosition();
    }
  }
}

export {
  FilterMap
}
