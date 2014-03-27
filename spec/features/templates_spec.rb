require 'spec_helper'

describe 'Templates' do

  it 'should require login' do
    visit templates_path
    expect(current_path).to eq '/users/sign_in'
  end

  it 'should redirect non-admin users' do
    sign_in :user
    visit templates_path
    expect(current_path).to eq '/contribute'
  end

  describe 'index page' do
    before :each do
      sign_in :admin
    end

    it 'has link to add templates' do
      visit templates_path
      expect(page).to have_selector("a[href='#{new_template_path}']" )
    end

    it 'has link to homepage' do
      visit templates_path
      find("#main-container").should have_link("Home")
    end

    context 'with some docs loaded' do

      let! (:tmpl1) { FactoryGirl.create(:tufts_template) }
      let! (:tmpl2) { FactoryGirl.create(:tufts_template) }
      let! (:pdf1 ) { FactoryGirl.create(:tufts_pdf) }
      let! (:aud1 ) { FactoryGirl.create(:tufts_audio) }

      before :each do
        visit templates_path
      end

      it 'lists the templates' do
        expect(page).to have_content(tmpl1.pid)
        expect(page).to have_content(tmpl2.pid)
      end

      it 'does not list other object types' do
        expect(page).not_to have_content(pdf1.pid)
        expect(page).not_to have_content(aud1.pid)
      end

      it 'has links to edit the templates' do
        expect(page).to have_link('Edit', href: HydraEditor::Engine.routes.url_helpers.edit_record_path(tmpl1.pid))
        expect(page).to have_link('Edit', href: HydraEditor::Engine.routes.url_helpers.edit_record_path(tmpl2.pid))
      end

      it 'has links to delete the templates' do
        expect(page).to have_link('Delete', href: record_path(id: tmpl1.pid))
        expect(page).to have_link('Delete', href: record_path(id: tmpl2.pid))
      end

    end

  end

end