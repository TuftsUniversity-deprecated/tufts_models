
function setupFileUpload(selectors) {
  $('.js-only').removeClass('hidden');
  $(selectors['selectFilesButton'] + ' input').addClass('overlay-select-files');

  // the jQuery File Upload widget:
  $(selectors['uploadForm']).fileupload({
    dataType: 'json',
  });

}
