$(function () {
    $('#fileupload').fileupload({
        dataType: 'json',
        progressall: function (e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $('.progress .bar').css(
                'width',
                progress + '%'
            );
        },
        add: function (e, data) {
            $('.progress').addClass('active').addClass('progress-striped');
            //data.context = $('<p/>').text('Uploading...').appendTo(document.body);
            data.submit();
        },
        done: function (e, data) {
            $('.progress').removeClass('active').removeClass('progress-striped');
            //data.context.text('Upload finished.');
        }
    });
});
