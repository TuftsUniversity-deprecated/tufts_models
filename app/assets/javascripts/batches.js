function setupFileUpload(selectors) {
  $('.js-only').removeClass('hidden');

  // Position the file input over the select files button.
  $(selectors['selectFilesButton'] + ' input').addClass('overlay-select-files');

  // The total number of files
  var file_count = 0;

  // The number of files that have been added but not yet uploaded.
  var queue_length = 0;

  // If the 'Next' button is marked as disabled, don't follow
  // the link if the user clicks it.
  next_link = $(selectors['nextButton']);
  next_link.click(function(e) {
    if (next_link.hasClass('disabled')) {
      e.preventDefault();
    }
  });

  // Enable 'Next' button only if all the added files have been uploaded.
  function setNextButtonState() {
    if(queue_length == 0 && file_count > 0) {
      next_link.removeClass('disabled');
    } else {
      next_link.addClass('disabled');
    }
  }
  next_link.addClass('disabled');

  // the jQuery File Upload widget:
  $(selectors['uploadForm']).fileupload({
    dataType: 'json',

    // This gets called when a file is added.
    add: function(e, data) {
      var that = this;
      queue_length = queue_length + 1;
      file_count = file_count + 1;
      setNextButtonState();

      // Call super
      $.blueimp.fileupload.prototype.options.add.call(that, e, data);
    },

    // Whether upload succeeds or fails, enable 'Next' button.
    always: function(e, data) {
      queue_length = queue_length - 1;
      setNextButtonState();
      next_link.removeClass('disabled');
    },

    // This gets called when user clicks 'cancel' for any added file.
    fail: function(e, data) {
      var that = this;
      queue_length = queue_length - 1;
      file_count = file_count - 1;
      setNextButtonState();

      // Call super
      $.blueimp.fileupload.prototype.options.fail.call(that, e, data);
    },
  });
}
