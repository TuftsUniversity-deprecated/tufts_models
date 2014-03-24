function setButtonDisabledState(data){
  // if any checkboxes are checked, enable the batch-create buttons
  var anyChecked = false;
  data.singleCheckboxes.map(function(index, element){
    anyChecked = anyChecked || element.checked;
  });
  data.buttons.prop("disabled", !anyChecked)
}

function updateCheckedCounter(data){
  var checkedCount = 0;
  data.singleCheckboxes.map(function(index, element){
    if(element.checked) { checkedCount += 1; }
  });
  data.selectedDocumentsCount.text("Number of documents selected: " + checkedCount);
}

function handleCheckSingleClick(e){
  // make the check_all box be checked if all the other checkboxes are checked
  var allChecked = true;
  e.data.singleCheckboxes.map(function(index, element){
    allChecked = allChecked && element.checked;
  });
  e.data.checkAll.prop("checked", allChecked);
  setButtonDisabledState(e.data);
  updateCheckedCounter(e.data);
}

function handleCheckAllClick(e){
  // if the check_all box is clicked, make all the other checkboxes match its state
  e.data.singleCheckboxes.prop("checked", e.target.checked);
  setButtonDisabledState(e.data);
  updateCheckedCounter(e.data);
}

$(document).ready(function() {
  batchElements = {
    checkAll: $('#documents #check_all'),
    singleCheckboxes: $('#documents .batch_document_selector'),
    buttons: $('[data-behavior=batch-create]'),
    selectedDocumentsCount: $('#selected_documents_count')
  }
  $('#documents #check_all').bind('click', batchElements, handleCheckAllClick);
  $('#documents .batch_document_selector').bind('click', batchElements, handleCheckSingleClick);

  // set initial state of buttons
  setButtonDisabledState(batchElements);
  updateCheckedCounter(batchElements);
});
