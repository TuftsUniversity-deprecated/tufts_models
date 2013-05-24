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
            $('.progress', $form).removeClass('hidden').addClass('active').addClass('progress-striped');
            data.submit();
        },
        done: function (e, data) {
            $form = $(this).closest('form');
            $('.progress', $form).removeClass('active').removeClass('progress-striped');
        },
        fail: function (e, data) {
          $('.progress', $form).removeClass('active').removeClass('progress-striped');
          console.log(data.jqXHR);
          alert("There was an error attaching your file: " + data.errorThrown);
        }
    });

    /** Style the buttons **/
    var wrapper = $('<div/>').css({height:0,width:0,'overflow':'hidden'});
    var fileInput = $(':file').wrap(wrapper);

    fileInput.change(function(){
        $form = $(this).closest('form');
        $('.file', $form).hide();
    })

    $('.file').click(function(){
        $form = $(this).closest('form');
        $(':file', $form).click();
    }).show();
});
