$(function () {
    $("[id$='_destroy']").change(function(e)
    {
        let destroy_char_count = 8;
        let str = e.target.id.slice(0, -destroy_char_count);
        let opacity;
        if (e.target.checked) {
            opacity = 0.3
        } else {
            opacity = 1
        }
        $("[id^=" + str + "]").css("opacity", opacity);
        $("[for^=" + str + "]").css("opacity", opacity);
        $(e.target).css("opacity", "1");
        $("[for^=" + e.target.id + "]").css("opacity", "1");
    })
});