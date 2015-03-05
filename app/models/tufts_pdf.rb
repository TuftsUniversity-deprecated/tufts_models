class TuftsPdf < TuftsBase
  has_file_datastream 'Archival.pdf', control_group: 'E', original: true


  # @param [String] _ Datastream id - not used
  # @param [String] type the content type to test
  # @return [Boolean] true if type is a valid mime type for pdf
  def valid_type_for_datastream?(_, type)
      self.class.valid_pdf_mime_type?(type)
  end


  def self.valid_pdf_mime_type?(type)
    %Q{application/pdf application/x-pdf application/acrobat applications/vnd.pdf text/pdf text/x-pdf}.include?(type)
  end


  def self.to_class_uri
    'info:fedora/cm:Text.PDF'
  end


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


  # To cause create_derivatives to be invoked, execute this line of code in rails console:
  # Job::CreateDerivatives.new('uuid', 'record_id' => '<pid beginning with tufts:>').perform
  def create_derivatives
    begin
      log_file = File.open(Rails.root.join('log', 'derivatives.log'), 'a')
      log_file.sync = true  # flush each log message immediately
      logger = Logger.new(log_file)
      logger.formatter = proc do |severity, datetime, progname, msg| "#{msg}\n" end
      logger.info(DateTime.parse(Time.now.to_s).strftime('%A %B %-d, %Y %I:%M:%S %p'))

      file_asset = ActiveFedora::Base.find(pid)

      if file_asset.nil?
        logger.fatal('Can\'t create PDF derivatives for ' + pid + '.  Object not found.')
      else
        unless file_asset.datastreams.include?('Archival.pdf')
          logger.fatal('Can\'t create PDF derivatives for ' + pid + '.  Object does not have an Archival.pdf datastream.')
        else
          pdf_path = local_path_for('Archival.pdf')
          logger.info('Creating PDF derivatives for ' + pid + '.')

          pdf_pages = Magick::Image.read(pdf_path){self.density = '150x150'}  # meaning 150 dpi
          logger.info('  Archival PDF is at ' + pdf_path + '.')

          page_count = pdf_pages.length
          page_width = pdf_pages[0].columns
          page_height = pdf_pages[0].rows
          logger.info('  Found ' + page_count.to_s + ' page' + (page_count == 1 ? '' : 's') + ' (' + page_width.to_s + ' x ' + page_height.to_s + ').')

          derivatives_path = local_path_for_pdf_derivatives()
          FileUtils.mkdir_p(derivatives_path)

          book_meta_path = local_path_for_book_meta(derivatives_path)
          book_meta_json = '{"page_width":"' + page_width.to_s + '","page_height":"' + page_height.to_s + '","page_count":"' + page_count.to_s + '"}'
          logger.info('  Writing ' + book_meta_json + ' to ' + book_meta_path + '.')
          File.open(book_meta_path, 'w'){|file| file.puts(book_meta_json)}

          readme_path = local_path_for_readme(derivatives_path)
          readme_text = 'Created by MIRA from source: ' + pdf_path
          logger.info('  Writing ' + readme_text + ' to ' + readme_path + '.')
          File.open(readme_path, 'w'){|file| file.puts(readme_text)}

          page_number = 0
          filename_base = pid_without_namespace

          pdf_pages.each do |pdf_page|
            png_path = local_path_for_png(page_number, derivatives_path, filename_base)
            logger.info('  Writing ' + png_path + '.')

            pdf_page.write(png_path){self.quality = 100}  # meaning 100% quality
            pdf_page.destroy!  # this is important - without it RMagick can occasionally be left in a state that causes subsequent failures
            pdf_pages[page_number] = nil

            page_number += 1
          end

        logger.info('Successfully created PDF derivatives for ' + pid + '.')
        end
      end
    rescue Magick::ImageMagickError => ex
      logger.fatal('Can\'t create PDF derivatives for ' + pid +  '.  ImageMagick error: ' + ex.message)
      raise(ex)
    rescue SystemCallError => ex
      logger.fatal('Can\'t create PDF derivatives for ' + pid +  '.  I/O error: ' + ex.message)
      raise(ex)
    rescue StandardError => ex
      logger.fatal('Can\'t create PDF derivatives for ' + pid +  '.  error: ' + ex.message)
      raise(ex)
    ensure
      logger.info(DateTime.parse(Time.now.to_s).strftime('%A %B %-d, %Y %I:%M:%S %p'))
      logger.info('')  # blank line between events
    end
  end


end
