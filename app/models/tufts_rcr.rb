class TuftsRCR < TuftsBase

  #MK 2011-04-13 - Are we really going to need to access FILE-META from FILE-META.  I'm guessing
  # not.
  has_metadata :name => "FILE-META", :type => TuftsFileMeta

  has_metadata :name => "RCR-CONTENT", :type => TuftsRcrMeta
end
