require 'spec_helper'

describe WithPageImages do

  subject {TuftsPdf.new pid: 'tufts:sd.01', title: 'some title', displays: ['dl'] }

  describe  '#local_path_for_pdf_derivatives' do
    it 'returns the path where the page turner package should be written' do
      expect(subject.local_path_for_pdf_derivatives).to eq  File.expand_path("../../../fixtures/local_object_store/dcadata02/tufts/central/dca/sd/access_pdf_pageimages/sd.01", __FILE__)
    end
  end

  describe  '#local_path_for_readme' do
    it 'returns the path where readme should be written' do
      expect(subject.local_path_for_readme).to eq  File.expand_path("../../../fixtures/local_object_store/dcadata02/tufts/central/dca/sd/access_pdf_pageimages/sd.01/readme.txt", __FILE__)
    end
  end

  describe '#local_path_for_book_meta' do
    it 'returns the path where book meta should be written' do
      expect(subject.local_path_for_book_meta).to eq  File.expand_path("../../../fixtures/local_object_store/dcadata02/tufts/central/dca/sd/access_pdf_pageimages/sd.01/book_meta.json", __FILE__)
    end
  end

  describe '#local_path_for_png' do
    it 'returns the path where page images should be written' do
      expect(subject.local_path_for_png 1).to eq  File.expand_path("../../../fixtures/local_object_store/dcadata02/tufts/central/dca/sd/access_pdf_pageimages/sd.01/sd.01-1.png", __FILE__)
    end
  end

end
