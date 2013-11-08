require 'spec_helper'

describe 'Contribute' do

  it 'should be default path for unauthenticated users' do
    #visit destroy_user_session_path
    visit '/'
    current_path.should == '/contribute'
  end

  it 'should be the default root for authenticated non-admin users' do
    sign_in :user
    visit '/'
    current_path.should == '/contribute'
  end

  describe "Landing Page" do

    describe 'for unauthenticated users' do
      before :all do
        visit destroy_user_session_path
      end
      it 'should exist' do
        visit '/contribute'
        current_path.should == contributions_path
      end
      it 'should give a login option' do
        visit '/contribute'
        expect(page).to have_content 'Tufts Simplified Sign-On Enabled'
        expect(page).to have_link 'Login'
      end
      describe "with a deposit type" do
        let!(:deposit_type) { FactoryGirl.create(:deposit_type, :display_name => 'Test Option', :deposit_view => 'generic_deposit') }
        it 'should show configured deposit type options' do
          visit '/contribute'
          expect(page).to have_content 'Test Option'
        end
      end
    end
    describe 'for authenticated users' do
      before :each do
        sign_in :user
      end
      it 'should exist' do
        visit '/contribute'
        current_path.should == contributions_path
      end
      it 'should let users select a deposit type' do
        visit '/contribute'
        page.should have_select 'deposit_type'
      end
      it 'should provide a button to create new deposits' do
        page.should have_button 'Begin'
      end
    end
  end

  describe 'License Page' do
    it 'should contain the license description' do
      visit '/contribute/license'
      expect(page).to have_content 'Non-Exclusive Deposit License'
    end
  end

  describe 'New file deposit page' do
    it 'should redirect unauthenticated users to the sign-on page' do
      visit destroy_user_session_path # Force logout, just in case...
      visit '/contribute/new'
      current_path.should == new_user_session_path
    end
    describe 'for authenticated users' do
      before { sign_in :user }

      it 'should redirect the user to the selection page is the deposit type is missing' do
        visit '/contribute/new'
        current_path.should == contributions_path
      end
      it 'should redirect the user to the selection page is the deposit type is invalid' do
        visit '/contribute/new?type=bad_deposit_type'
        current_path.should == contributions_path
      end

      describe "capstone_project" do
        let(:capstone_type) { FactoryGirl.create(:deposit_type, deposit_view: 'capstone_project') }
        it "should draw capstone form" do
          visit "/contribute/new?deposit_type=#{capstone_type.id}"
          select 'MIB', from: 'Degree'
          click_button "Agree & Deposit"
          expect(page).to have_content "Title can't be blank"
          expect(page).to have_content "Abstract can't be blank"
          expect(page).to have_content "Attachment can't be blank"
          fill_in 'Capstone project title', with: 'Test title'
          fill_in 'Abstract', with: 'Test abstract'
          attach_file 'File to upload', File.join(fixture_path, '/local_object_store/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf')
          click_button "Agree & Deposit"
          expect(page).to have_content "Your file has been saved!"

        end
      end

      describe "honors_thesis" do
        let(:honors_thesis_type) { FactoryGirl.create(:deposit_type, deposit_view: 'honors_thesis') }
        it "should draw honors_thesis form" do
          visit "/contribute/new?deposit_type=#{honors_thesis_type.id}"
          fill_in 'Department', with: 'Dept. of Biology'
          click_button "Agree & Deposit"
          expect(page).to have_content "Title can't be blank"
          expect(page).to have_content "Abstract can't be blank"
          expect(page).to have_content "Attachment can't be blank"
          fill_in 'Thesis title', with: 'Test title'
          fill_in 'Abstract', with: 'Test abstract'
          attach_file 'File to upload', File.join(fixture_path, '/local_object_store/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf')
          click_button "Agree & Deposit"
          expect(page).to have_content "Your file has been saved!"
        end
      end

      describe "faculty_scholarship" do
        let(:faculty_scholarship_type) { FactoryGirl.create(:deposit_type, deposit_view: 'faculty_scholarship') }

        it "should draw faculty_scholarship form" do
          visit "/contribute/new?deposit_type=#{faculty_scholarship_type.id}"
          click_button "Agree & Deposit"
          expect(page).to have_content "Title can't be blank"
          expect(page).to have_content "Abstract can't be blank"
          expect(page).to have_content "Attachment can't be blank"
          fill_in 'Title', with: 'Test title'
          fill_in 'Abstract', with: 'Test abstract'
          attach_file 'File to upload', File.join(fixture_path, '/local_object_store/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf')

          # These divs are needed for the javascript multiForm.js from hydra-editor
          # in order to allow users to add extra input fields for other_authors
          page.assert_selector('form.editor')
          page.assert_selector('.control-group #additional_other_authors_clone #additional_other_authors_submit')
          expect(page).to have_selector('input[name="contribution[other_authors][]"]')

          click_button "Agree & Deposit"
          expect(page).to have_content "Your file has been saved!"
        end
      end

      describe "qualifying_paper" do
        let(:qualifying_paper_type) { FactoryGirl.create(:deposit_type, deposit_view: 'qualifying_paper') }

        it "should draw faculty_scholarship form" do
          visit "/contribute/new?deposit_type=#{qualifying_paper_type.id}"
          click_button "Agree & Deposit"
          expect(page).to have_content "Title can't be blank"
          expect(page).to have_content "Abstract can't be blank"
          expect(page).to have_content "Attachment can't be blank"
          fill_in 'Title', with: 'Test title'
          fill_in 'Abstract', with: 'Test abstract'
          attach_file 'File to upload', File.join(fixture_path, '/local_object_store/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf')
          click_button "Agree & Deposit"
          expect(page).to have_content "Your file has been saved!"

        end
      end
      describe "generic_deposit" do
        let(:generic_deposit_type) { FactoryGirl.create(:deposit_type, deposit_view: 'generic_deposit') }

        it "should draw faculty_scholarship form" do
          visit "/contribute/new?deposit_type=#{generic_deposit_type.id}"
          click_button "Agree & Deposit"
          expect(page).to have_content "Title can't be blank"
          expect(page).to have_content "Abstract can't be blank"
          expect(page).to have_content "Attachment can't be blank"
          fill_in 'Title', with: 'Test title'
          fill_in 'Abstract', with: 'Test abstract'
          attach_file 'File to upload', File.join(fixture_path, '/local_object_store/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf')
          click_button "Agree & Deposit"
          expect(page).to have_content "Your file has been saved!"

        end
      end
    end
  end
end
