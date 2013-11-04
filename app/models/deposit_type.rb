class DepositType < ActiveRecord::Base

  PARTIAL_PATH = 'app/views/contribute/metadata'
  attr_accessible :display_name, :deposit_view, :deposit_agreement

  validates :display_name, presence: true, uniqueness: true
  validates :deposit_view, presence: true
  validates_each(:deposit_view) {|record, attr, value| record.errors.add(attr, "must name a valid partial in #{PARTIAL_PATH}") unless valid_desposit_views.include? value}

  before_save :sanitize_deposit_agreement

  def self.valid_desposit_views
    return Dir.glob("#{PARTIAL_PATH}/_*.html.erb").collect{|f| File.basename(f,".html.erb")[1..-1]}
  end

protected

  # Since we are allowing HTML input and using the
  # 'raw' method to display the deposit_agreement,
  # we need to sanitize the data.
  def sanitize_deposit_agreement
    self.deposit_agreement = Sanitize.clean(self.deposit_agreement, Sanitize::Config::BASIC)
  end

end
