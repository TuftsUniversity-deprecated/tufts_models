(function( $ ){
  $.fn.genericForm = function( options ) {  

    // Use a global counter, so that no two rows will have same numbers if one row is removed and then a new row is added
    var counter = 0

    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);

    function addField() {
      var $this = $(this);
      var row = $this.closest('tr');
      newRow = row.clone();
      var tbody = $this.closest('tbody');
      tbody.append(newRow);
      
      counter++;
      var number = newRow.find('.row_num').html(counter);
      // change the add button to a remove button
      var plusbttn = newRow.find('.adder');
      plusbttn.html('<i class="icon-minus"></i><span class="accessible-hidden">remove this row</span>');
      plusbttn.on('click',removeField);

      //clear out the value for the element being appended
      //so the new element has a blank value
      newRow.find('input[type=text]').val('');
      newRow.find('input[type=text]').attr("required", false);

      // if (settings.afterAdd) {
      //   settings.afterAdd(this, newRow);
      // }

      newRow.find('input[type=text]').each(function() {
        old_name = $(this).prop('name');
        $(this).prop('name', old_name.replace('0', counter - 1));
      });
      newRow.find('input[type=text]').first().focus();
      return false;
    }

    function removeField () {
      // get parent and remove it
      $(this).closest('tr').remove();
      return false;
    }

    return this.each(function() {        

      // Tooltip plugin code here
      /*
       * adds additional metadata elements
       */
      counter = $('tbody tr', this).length;
      $('.adder', this).click(addField);

      $('.remover', this).click(removeField);
    });
  };
})( jQuery );  

$(function() {
  $('form.generic').genericForm();
});


