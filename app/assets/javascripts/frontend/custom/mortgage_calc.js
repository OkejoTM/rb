// Calculator
function mortgageCalc() {

    var amount = parseFloat($("#amount").val().replace(/[^0-9\.]+/g,"")),
        months =parseFloat($("#years").val().replace(/[^0-9\.]+/g,"")*12),
        down = parseFloat($("#downpayment").val().replace(/[^0-9\.]+/g,"")),
        annInterest = parseFloat($("#interest").val().replace(/[^0-9\.]+/g,"")),
        monInt = annInterest / 1200,
        calculation = ((monInt + monInt / (Math.pow(1 + monInt, months) - 1)) * (amount - (down || 0))).toFixed(2);

    if (calculation > 0 ){
        $(".calc-output-container").css({'opacity' : '1', 'max-height' : '200px' });
        $(".calc-output").hide().html(calculation + ' ' + $('.mortgageCalc').attr("data-calc-currency")).fadeIn(300);
    }
}

export { mortgageCalc };