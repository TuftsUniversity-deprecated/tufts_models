module RecordsHelper
  include RecordsHelperBehavior

  
  def object_type_options
    {'Audio' => 'TuftsAudio', 'PDF' => 'TuftsPdf'}
  end
end
