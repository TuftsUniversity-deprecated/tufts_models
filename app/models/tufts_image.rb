class TuftsImage < TuftsBase

  #'Thumbnail.png', 'Archival.tif', 'Advanced.jpg'

  def to_solr(solr_doc=Hash.new, opts={})
    #prefilter perseus and art history objects
    if ['perseus','aah'].any? { |word| pid.include?(word) }
      return solr_doc
    end

    #also filter year book pages and election images
    if ['tufts:UP150','tufts:MS115.001'].any? { |word| pid.starts_with?(word) }
          return solr_doc
    end

    solr_doc = super
    index_sort_fields solr_doc
    index_fulltext solr_doc
    return solr_doc
  end

  def self.to_class_uri
    'info:fedora/cm:Image.4DS'
  end
end
