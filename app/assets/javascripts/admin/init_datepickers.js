$(function () {
    $('#sandbox-container .input-daterange, .datepicker').datepicker({
        language: "ru",
        daysOfWeekHighlighted: "0,6",
        format: 'dd-mm-yyyy',
        autoclose: true,
        todayHighlight: true,
        endDate: new Date()
    });

    $('#reports_start_date').on('change', function() {
        $('#reports_end_date').datepicker('setStartDate', $('#reports_start_date').val());
        $('#reports_end_date').datepicker("show");
    });
});