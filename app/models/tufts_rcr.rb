class TuftsRCR < TuftsBase

  #MK 2011-04-13 - Are we really going to need to access FILE-META from FILE-META.  I'm guessing
  # not.
  has_metadata :name => "FILE-META", :type => TuftsFileMeta

  has_metadata :name => "RCR-CONTENT", :type => TuftsRcrMeta

  def to_solr(solr_doc=Hash.new, opts={})
    super
    index_sort_fields solr_doc
    return solr_doc
  end

end
