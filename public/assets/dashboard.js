var REFRESH_TIMEOUT = 120000;

function refresh() {
    window.location.reload();
}

function update() {
    if (!window.loadedTime) {
        window.loadedTime = new Date();
    }
    var secsLeft = (REFRESH_TIMEOUT - (new Date() - window.loadedTime)) / 1000;
    $('#time').text(parseInt(secsLeft, 10));
}

$(function() {
    if ($('#refresh').is(":checked")) {
        window.refresher = setTimeout(refresh, REFRESH_TIMEOUT);
        $('#time').show();
        window.timer = setInterval(update, 1000);
    }
});