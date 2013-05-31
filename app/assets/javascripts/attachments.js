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

            // Don't let the user click the save button while upload is in progress
            $('.btn-primary').prop("disabled", true);
        },
        done: function (e, data) {
            if (data.jqXHR.responseText) {
              result = JSON.parse(data.jqXHR.responseText);
              if (result.message) {
                alert(result.message);
              }
            }
            $form = $(this).closest('form');
            $('.progress', $form).removeClass('active').removeClass('progress-striped');

            // Enable the save button only if all forms have finished upload
            if ($('.progress.active').length == 0)
              $('.btn-primary').prop("disabled", false);
              
        },
        fail: function (e, data) {
          $('.progress', $form).removeClass('active').removeClass('progress-striped');
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
