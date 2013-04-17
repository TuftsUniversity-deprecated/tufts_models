module Tufts
  module ModelUtilityMethods
   def self.clean_ead_title(title)
     if title.starts_with? 'A Guide to the'
      title = title.gsub('A Guide to the','')
     elsif title.starts_with? 'A Guide to The'
      title = title.gsub('A Guide to','')
     end

     title
   end
  end
end

