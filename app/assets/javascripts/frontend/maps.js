import { PropertyMap } from './maps/property_map'
import { FilterMap } from './maps/filter_map'

$(window).on('load', function () {

  let $propertyMap = $('#propertyMap');
  if(!_.isNil($propertyMap[0])) {
    let propertyMap = new PropertyMap($propertyMap);
    propertyMap.call();
  }

  let $map = $('#map');
  if(!_.isNil($map[0])) {
    let map = new FilterMap($map);
    map.call();
  }
});
