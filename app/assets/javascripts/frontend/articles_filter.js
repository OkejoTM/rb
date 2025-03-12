$(function () {
    if ($('#articles_list').length > 0) {
        let article_category_handler = function() {
            $('.article_category').click(function(e) {
                $('.article_category').removeClass('link_active');
                $(this).addClass('link_active');

                $('#page').val(0);
                update_articles_list();

                return false;
            });
        };

        article_category_handler();

        $('#country_url').change(function(e) {
            $('.article_category').removeClass('link_active');

            $('#page').val(0);
            update_articles_list();
        });

        let update_articles_list = function() {
            $('#articles_list').addClass('loading');
            $('#article_categories').addClass('loading');

            req_props = [
                // {name: 'country_or_category_url', value: $('#country_id').val()},
                {name: 'url', value: location.pathname},
                {name: 'country_url', value: $('#country_url').val()},
                {name: 'article_category_url', value: $('.article_category.link_active').attr('data-category-url')},
                {name: 'page', value: $('#page').val()}
            ];

            $.ajax({
                method: "GET",
                url: `/${PROPIMO_LOCALE}/articles_list`,
                data: req_props,
                dataType: "json"
            }).done(function( data ) {
                $('#articles_list').removeClass('loading').empty().append(data['partial']);

                $('#article_categories').removeClass('loading').empty().append(data['article_categories']);

                article_category_handler();

                $('#breadcrumbs').empty().append(data['breadcrumbs']);

                document.title = data['title'];

                window.history.replaceState({}, "", data['url']);

                jQuery.each(data['alternative_urls'], function(key, value) {
                    $("#locale_" + key).attr('href', value);
                });

                pagination_handler();
            });
        };

        let pagination_handler = function() {
            $("div .pagination ul li a, div .pagination-next-prev ul li a").click(function (e) {
                $('#page').val($(this).attr('page'));

                update_articles_list();

                return false;
            });
        };

        pagination_handler();
    }
});