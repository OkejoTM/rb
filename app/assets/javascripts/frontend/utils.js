// Определяет тип девайса по экрану
// Истина, если девайс мобильный
// return [Boolean]
function deviceMobile() {
  return window.innerWidth <= 800 && window.innerHeight <= 850;
}

export {
  deviceMobile
}
