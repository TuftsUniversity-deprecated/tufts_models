$(function () {
    $('.fileupload').fileupload({
        dataType: 'json',
        progressall: function (e, data) {
            $form = $(this).closest('form');
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $('.progress .bar', $form).css(
                'width',
                progress + '%'
            );
        },
        add: function (e, data) {
            $form = $(this).closest('form');
            $('.progress', $form).addClass('active').addClass('progress-striped');
            data.submit();
        },
        done: function (e, data) {
            $form = $(this).closest('form');
            $('.progress', $form).removeClass('active').removeClass('progress-striped');
        }
    });
});
