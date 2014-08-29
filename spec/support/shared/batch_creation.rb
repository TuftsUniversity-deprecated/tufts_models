require 'spec_helper'

shared_examples 'requires a list of pids' do |batch_factory|

  context 'error path - no pids were selected:' do

    it 'redirects to previous page' do
      allow(controller.request).to receive(:referer) { catalog_index_path }
      post :create, batch: FactoryGirl.attributes_for(batch_factory, pids: [])
      expect(response).to redirect_to(request.referer)
    end

    it 'redirects to root if there is no referer' do
      post :create, batch: FactoryGirl.attributes_for(batch_factory, pids: [])
      expect(response).to redirect_to(root_path)
    end

    it 'sets the flash' do
      post :create, batch: FactoryGirl.attributes_for(batch_factory, pids: [])
      expect(flash[:error]).to eq 'Please select some records to do batch updates.'
    end

  end
end


shared_examples 'batch creation happy path' do |batch_class|
  let(:factory_name) { batch_class.to_s.underscore.to_sym }
  let(:different_user) { FactoryGirl.create(:admin) }

  it 'assigns the current user as the creator' do
    allow_any_instance_of(batch_class).to receive(:run).and_return(true)
    attrs = FactoryGirl.attributes_for(factory_name, creator_id: different_user.id)
    post 'create', batch: attrs

    expect(assigns[:batch].creator).to eq controller.current_user
  end

  it 'creates a batch' do
    allow_any_instance_of(batch_class).to receive(:run).and_return(true)
    batch_count = Batch.count
    post 'create', batch: FactoryGirl.attributes_for(factory_name)
    expect(Batch.count).to eq batch_count + 1
  end

  it 'assigns @batch' do
    allow_any_instance_of(batch_class).to receive(:run).and_return(true)
    post 'create', batch: FactoryGirl.attributes_for(factory_name)
    expect(assigns[:batch].class).to eq batch_class
  end

  it 'runs the batch' do
    batch = Batch.new(FactoryGirl.attributes_for(factory_name))
    allow(Batch).to receive(:new) { batch }
    expect(batch).to receive(:run) { true }
    post 'create', batch: FactoryGirl.attributes_for(factory_name)
  end

  it 'redirects to the batch show page' do
    allow_any_instance_of(batch_class).to receive(:run).and_return(true)
    post 'create', batch: FactoryGirl.attributes_for(factory_name)
    expect(response).to redirect_to(batch_path(assigns[:batch]))
  end
end


shared_examples 'batch run failure recovery' do |batch_class|
  let(:factory_name) { batch_class.to_s.underscore.to_sym }
  let(:attrs) { FactoryGirl.attributes_for(factory_name) }

  before do
    allow_any_instance_of(batch_class).to receive(:run).and_return(false)
  end

  context 'error path - batch fails to run:' do

    it 'sets the flash' do
      allow_any_instance_of(batch_class).to receive(:save).and_return(true)
      post :create, batch: attrs
      expect(flash[:error]).to eq 'Unable to run batch, please try again later.'
    end

    it "doesn't create a batch object" do
      batch_count = Batch.count
      post 'create', batch: attrs
      expect(Batch.count).to eq batch_count
    end

    it 'still assigns @batch' do
      post 'create', batch: attrs
      expect(assigns[:batch].pids).to eq attrs[:pids]
      expect(assigns[:batch].new_record?).to be_truthy
    end
  end
end

