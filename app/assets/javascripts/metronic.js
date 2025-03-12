var req = require.context("./metronic/", true, /^(.*\.(js\.*))[^.]*$/)
req.keys().forEach(function(key){
    req(key);
})