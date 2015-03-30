module WithPageImages
  extend ActiveSupport::Concern

  def local_path_for_pdf_derivatives
    # Convert the local path for the archival pdf into the local path for the derivatives folder:
    #   - replace '/data01/' or '/data05/' with '/dcadata02/';
    #   - if the path contains '/facpubs/' replace '/archival_pdf/' with '/access_pdf_pageimages/facpubs.', otherwise with '/access_pdf_pageimages/';
    #   - replace '.archival.pdf' with nothing.

    derivatives_path = local_path_for('Archival.pdf')

    derivatives_path.sub(/\/data\d\d\//, '/dcadata02/').sub(/\/archival_pdf\//, '/access_pdf_pageimages/' + (derivatives_path.match(/\/facpubs\//) ? 'facpubs.' : '')).sub(/\.archival\.pdf/, '')
  end


  def local_path_for_readme(derivatives_path = local_path_for_pdf_derivatives)
    derivatives_path + '/readme.txt'
  end


  def local_path_for_book_meta(derivatives_path = local_path_for_pdf_derivatives)
    derivatives_path + '/book_meta.json'
  end


  def local_path_for_png(page_number, derivatives_path = local_path_for_pdf_derivatives, filename_base = pid_without_namespace)
    derivatives_path + '/' + filename_base + "-" + page_number.to_s + '.png'
  end

end