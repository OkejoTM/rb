import '../typeahead/bootstrap3-typeahead';
import { callMetrika } from './call_metrika.js'

var ready;

var substringMatcher = function(strs) {
    return function findMatches(q, cb) {
        var matches, substrRegex;

        // an array that will be populated with substring matches
        matches = [];

        // regex used to determine if a string contains the substring `q`
        substrRegex = new RegExp(q, 'i');

        // iterate through the pool of strings and for any string that
        // contains the substring `q`, add it to the `matches` array
        $.each(strs, function(i, str) {
            matches.push(str);
        });

        cb(matches);
    };
};

var specialKeyCodeMap = {
    9: "tab",
    27: "esc",
    37: "left",
    39: "right",
    13: "enter",
    38: "up",
    40: "down"
};

ready = function() {
    //Метрика нажатий кнопки "Больше условий"
    $('#main-more-options').click(function () {
        callMetrika('submit-main-more-options-btn');
    });

    var res_cities = [];
    var res_regions = [];
    var res_countries = [];

    var links = [];
    var queryVal;

    let get_locations = function (e) {
        if (specialKeyCodeMap[e.which || e.keyCode]) {
            return;
        }

        queryVal = $('#query').val();
        $('#loading-icon').show();

        setTimeout(function(qv) {
            if (qv == $('#query').val()) {

                $.getJSON("/" + PROPIMO_LOCALE + '/autocomplete?query=' + qv, function (data) {
                    res_cities = data["Cities"];
                    links = data["links"];
                    res_regions = data["Regions"];
                    res_countries = data["Countries"];

                    i18next.changeLanguage(PROPIMO_LOCALE);
                    var wasOnFocus = $('#query').is(":focus");

                    if (res_cities.length == 0 && res_regions.length == 0 && res_countries.length == 0) {
                        var no_result = document.createElement("h3");
                        no_result.innerText = i18next.t('no_results');
                        no_result.setAttribute('class', 'no_result');
                        var $menu = $('#multiple-datasets .tt-menu');
                        $menu.empty();
                        $menu.append(no_result);
                    } else {
                        var $typeahead = $('#multiple-datasets .typeahead');

                        $typeahead.typeahead('destroy');

                        $typeahead.typeahead(
                            {
                                minLength: 0,
                                highlight: true
                            },
                            generateHashForTypeahead('cities'),
                            generateHashForTypeahead('regions'),
                            generateHashForTypeahead('countries'),
                        );
                    }

                    if(wasOnFocus || queryVal == '') {
                        $('#query').focus();
                    }

                    $('#loading-icon').hide();
                });
            }
        }, 1000, queryVal);
    };

    $('#query').keyup(get_locations);

    $('#query').click(function (e) {
        if ($(this).val() == '') {
            get_locations(e);
        }
    });

    function generateHashForTypeahead(name){
        var typeahedName = name;
        var typeaheadSource;
        var typeaheadHeader;
        switch(name){
            case 'cities':
                typeaheadSource = res_cities;
                typeaheadHeader = i18next.t('cities');
                break;
            case 'regions':
                typeaheadSource = res_regions;
                typeaheadHeader = i18next.t('regions');
                break;
            case'countries':
                typeaheadSource = res_countries;
                typeaheadHeader = i18next.t('countries');
                break;
        }

        return {
            name: typeahedName,
            source: substringMatcher(typeaheadSource),
            templates: {
                header: '<h3 class="league-name">' + typeaheadHeader + '</h3>'
            }
        }

    }

    $('#currency').on('change', function () {
        $('#price_from').attr('data-unit', $(this).val());
        $('#price_from').siblings('i.data-unit').text($('#currency option:selected').val());

        $('#price_to').attr('data-unit', $(this).val());
        $('#price_to').siblings('i.data-unit').text($('#currency option:selected').val());
    });
}

$(document).ready(ready);
$(document).on('page:load', ready);
