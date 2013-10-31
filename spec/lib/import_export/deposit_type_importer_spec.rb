require 'spec_helper'
require_relative '../../../lib/import_export/deposit_type_importer'

describe DepositTypeImporter do

  describe 'initialize' do
    it 'sets the import_file' do
      file = test_import_file
      importer = DepositTypeImporter.new(file)
      importer.import_file.should == file
    end
  end

  it 'raises an exception if the import file is not found' do
    importer = DepositTypeImporter.new('/bad/path/no/file')
    expect {
      importer.import_from_csv
    }.to raise_error(ImportFileNotFoundError)
  end

  it 'raises an exception if the import file is not CSV' do
    not_a_csv_file = File.join(fixture_path, 'tufts_RCR00001.foxml.xml')
    importer = DepositTypeImporter.new(not_a_csv_file)
    expect {
      importer.import_from_csv
    }.to raise_error(ImportFileFormatError)
  end

  it 'imports CSV data' do
    importer = DepositTypeImporter.new(test_import_file)

    DepositType.count.should == 0
    importer.import_from_csv
    DepositType.count.should == 3

    pdf = DepositType.where(display_name: 'PDF Document').first
    pdf.deposit_agreement.should == 'Agreement for a PDF'
    pdf.deposit_view.should == 'capstone_project'
    audio = DepositType.where(display_name: 'Audio File').first
    audio.deposit_agreement.should == 'Agreement for Audio'
    audio.deposit_view.should == 'honors_thesis'
    photo = DepositType.where(display_name: 'Photograph').first
    photo.deposit_agreement.should == 'Agreement for a Photo'
    photo.deposit_view.should == 'generic_deposit'
  end

  it 'updates existing deposit types' do
    importer = DepositTypeImporter.new(test_import_file)
    pdf = FactoryGirl.create(:deposit_type, display_name: 'PDF Document', deposit_agreement: 'old text')
    DepositType.count.should == 1
    importer.import_from_csv
    DepositType.count.should == 3
    pdf.reload
    pdf.deposit_agreement.should == 'Agreement for a PDF'
    pdf.deposit_view.should == 'capstone_project'
  end

  it 'doesnt create duplicate deposit types' do
    DepositType.count.should == 0
    importer = DepositTypeImporter.new(File.join(fixture_path, 'import', 'deposit_types_with_duplicate_entries.csv'))
    importer.import_from_csv

    DepositType.count.should == 1
    DepositType.first.deposit_agreement.should == 'Agreement 3'
  end

  def test_import_file
    File.join(fixture_path, 'import', 'deposit_types.csv')
  end

end
