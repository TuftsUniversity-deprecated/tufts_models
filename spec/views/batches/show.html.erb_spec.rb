require 'spec_helper'

describe "batches/show.html.erb" do
  describe 'apply_template' do
    subject { FactoryGirl.create(:batch_template_update, pids: docs.map(&:id)) }
    let(:docs) { [FactoryGirl.create(:tufts_pdf)] }
    let(:jobs) { [] }

    before do
      assign :batch, subject
      assign :documents, docs
      assign :jobs, jobs
    end

    it "shows general information" do
      pending "reviews working on documents"
      render
      expect(rendered).to have_selector(".batch_id", text: subject.id)
      expect(rendered).to have_selector(".job_count", text: jobs.count)
      expect(rendered).to have_selector(".creator", text: subject.creator.display_name)
      expect(rendered).to have_selector(".created_at", text: subject.created_at)
      expect(rendered).to have_selector(".status", text: 'Complete')
      expect(rendered).to have_selector(".review_status", text: 'Complete')
    end

    it "shows document pids" do
      expect(rendered).to have_selector(".document_pid", text: docs.first.pid)
    end

    it "shows document titles" do
      expect(rendered).to have_selector(".document_title", text: docs.first.title)
    end

    it "shows document status" do
      expect(rendered).to have_selector(".document_status", text: "FIXME")
    end

    it "shows review status of each document" do
      expect(rendered).to have_selector(".document_reviewed_status", text: "Reviewed")
    end

    context "with some documents reviewed" do
      let(:docs) do
        d1 = FactoryGirl.create(:tufts_audio)
        d2 = FactoryGirl.create(:tufts_pdf)
        d1.reviewed!
        [d1, d2]
      end

      it "shows aa complete status when all docs have been reviewed" do
        render
        expect(rendered).to have_selector(".status", text: subject.id)
      end
    end

    context "with all documents reviewed" do
      let(:docs) do
        doc = FactoryGirl.create(:tufts_pdf)
        doc.reviewed!
        [doc]
      end

      it "shows an incomplete status when some docs haven't been reviewed" do
        render
        expect(rendered).to have_selector(".status", text: subject.id)
      end
    end
  end
end
