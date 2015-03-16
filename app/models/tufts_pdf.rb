class TuftsPdf < TuftsBase

  PDF_CONTENT_DS = 'Archival.pdf'

  has_file_datastream PDF_CONTENT_DS, control_group: 'E', original: true
  include WithPageImages

  # @param [String] _ Datastream id - not used
  # @param [String] type the content type to test
  # @return [Boolean] true if type is a valid mime type for pdf
  def valid_type_for_datastream?(_, type)
      self.class.valid_pdf_mime_type?(type)
  end


  def self.valid_pdf_mime_type?(type)
    %q{application/pdf application/x-pdf application/acrobat applications/vnd.pdf text/pdf text/x-pdf}.include?(type)
  end


  def self.to_class_uri
    'info:fedora/cm:Text.PDF'
  end

  # To cause create_derivatives to be invoked, execute this line of code in rails console:
  # Job::CreateDerivatives.new('uuid', 'record_id' => '<pid beginning with tufts:>').perform
  def create_derivatives


    begin

      if datastreams.include? PDF_CONTENT_DS
        derivative_settings = setup_derivative_environment

        create_page_turner_json derivative_settings
        create_readme derivative_settings
        create_pdf_page_images derivative_settings

      else
        logger.error("Can't create PDF derivatives for #{pid}.  Object does not have an Archival.pdf datastream.")
      end

    rescue Magick::ImageMagickError => ex
      logger.error("Can't create PDF derivatives for #{pid}.  ImageMagick error: #{ex.message}")
      raise(ex)
    rescue SystemCallError => ex
      logger.error("Can't create PDF derivatives for #{pid}.  I/O error: #{ex.message}")
      raise(ex)
    rescue StandardError => ex
      logger.error("Can't create PDF derivatives for #{pid}.  error: #{ex.message}")
      raise(ex)
    ensure
      logger.info(DateTime.parse(Time.now.to_s).strftime('%A %B %-d, %Y %I:%M:%S %p'))
      logger.info('') # blank line between events
    end
  end

  private

  def setup_derivative_environment
    derivative_settings = Hash.new

    pdf_path = derivative_settings[:pdf_path] = local_path_for PDF_CONTENT_DS

    DERIVATIVES_LOGGER.info("Creating PDF derivatives for #{pid}.")

    derivative_settings[:pdf] = Magick::Image.read(pdf_path) { self.density = '150x150' } # meaning 150 dpi

    DERIVATIVES_LOGGER.info("  Archival PDF is at #{pdf_path}.")

    derivative_settings[:pdf_meta] = extract_pdf_metadata derivative_settings
    derivative_settings[:derivatives_path] = create_derivatives_directory

    derivative_settings
  end

  def extract_pdf_metadata(derivative_settings)
    pdf_meta = Hash.new

    pdf = derivative_settings[:pdf]
    pdf_meta[:page_count] = pdf.length.to_s
    pdf_meta[:page_width] = pdf[0].columns.to_s
    pdf_meta[:page_height] = pdf[0].rows.to_s

    DERIVATIVES_LOGGER.info("  Found #{pdf_meta[:page_count]} page(s) (#{pdf_meta[:page_width]} x #{pdf_meta[:page_height]}).")

    pdf_meta
  end

  def create_derivatives_directory
    derivatives_path = local_path_for_pdf_derivatives
    FileUtils.mkdir_p(derivatives_path) #returns list
    derivatives_path
  end

  def create_pdf_page_images(derivative_settings)
    page_number = 0
    filename_base = pid_without_namespace
    pdf_pages = derivative_settings[:pdf]

    pdf_pages.each do |pdf_page|
      png_path = local_path_for_png(page_number, derivative_settings[:derivatives_path], filename_base)

      DERIVATIVES_LOGGER.info("  Writing #{png_path}.")

      pdf_page.write(png_path) { self.quality = 100 } # meaning 100% quality
      pdf_page.destroy! # this is important - without it RMagick can occasionally be left in a state that causes subsequent failures
      pdf_pages[page_number] = nil

      page_number += 1
    end

    DERIVATIVES_LOGGER.info("Successfully created PDF derivatives for #{pid}.")
  end

  def create_page_turner_json(derivative_settings)
    book_meta_path = local_path_for_book_meta(derivative_settings[:derivatives_path])
    book_meta_json = derivative_settings[:pdf_meta].to_json

    DERIVATIVES_LOGGER.info("Writing #{book_meta_json}  to #{book_meta_path}.")

    File.open(book_meta_path, 'w') { |file| file.puts(book_meta_json) }
  end

  def create_readme(derivatives_settings)
    readme_path = local_path_for_readme(derivatives_settings[:derivatives_path])
    readme_text = "Created by MIRA from source: #{derivatives_settings[:pdf_path]}"

    DERIVATIVES_LOGGER.info("  Writing #{readme_text} to  #{readme_path}.")

    File.open(readme_path, 'w') { |file| file.puts(readme_text) }
  end

end
