$(function () {

    function addSuccessMessage(msg) {
      $(".flash_messages").append('<div class="alert alert-notice">'+msg+'<a class="close" data-dismiss="alert" href="#">&times;</a></div>')

    }

    $('input#next').click(function(e) {
      if ($('.fileupload').attr('data-exists') == "false") {
        return confirm("You have not uploaded a datastream, do you want to continue?");
      }
    });

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

        // Setting these to null so that jquery-fileupload-ui doesn't try to use templates
        uploadTemplateId: null,
        downloadTemplateId: null,

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
              if (result.status == 'error') {
                alert(result.message);
              } else {
                addSuccessMessage(result.message);
              }
            }
            $form = $(this).closest('form');
            $('.progress', $form).removeClass('active').removeClass('progress-striped');
            $(this).attr('data-exists', 'yep');

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
    var fileInput = $('.fileupload').wrap(wrapper);

    fileInput.change(function(){
        $form = $(this).closest('form');
        $('.file', $form).hide();
    })

    $('.file').click(function(){
        $form = $(this).closest('form');
        $(':file', $form).click();
    }).show();
});
