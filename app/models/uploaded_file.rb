class UploadedFile < ActiveRecord::Base
  belongs_to :batch, class_name: 'BatchXmlImport'
end
