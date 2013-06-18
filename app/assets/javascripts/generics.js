(function( $ ){
  $.fn.genericForm = function( options ) {  

    // Use a global counter, so that no two rows will have same numbers if one row is removed and then a new row is added
    var counter = 0

    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);

    function update_number_in_name(field) {
        old_name = $(field).prop('name');
        $(field).prop('name', old_name.replace('0', counter - 1));
        old_id = $(field).prop('id');
        $(field).prop('id', old_id.replace('0', counter - 1));
    }


    function addField() {
      var $this = $(this);
      var row = $this.closest('tr');
      newRow = row.clone();
      var tbody = $this.closest('tbody');
      tbody.append(newRow);
      
      counter++;
      // Update the row to show 
      newRow.find('.row_num').html(counter);
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
        update_number_in_name(this, counter);
      });
      newRow.find('input[type=hidden]').each(function() {
        update_number_in_name(this, counter);
      });
      newRow.find('input#generic_item_attributes_'+ (counter-1) +'_item_id').val(counter);
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


