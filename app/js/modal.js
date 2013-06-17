(function() {
    $(document).ready(function() {
        $('#pdf-download').click(function() {

            $('#pdf-modal').reveal({
                animation: 'fade',
                animationspeed: 600,
                closeonbackgroundclick: true,
                dismissmodalclass: 'close'
            });

            return false;
        });
    });
})();
