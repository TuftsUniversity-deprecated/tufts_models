require 'spec_helper'

describe 'Version check for Blacklight' do

  describe 'blacklight_advanced_search gem' do

    it 'has a compatible version' do
      # According to the README for blacklight_advanced_search:
      # Version 2.2 of blacklight_advanced_search should work with blacklight 4.x.
      #
      # If this test fails, it's probably because you are
      # upgrading blacklight.  If so, you may also need to do
      # the following:
      #   * Upgrade blacklight_advanced_search gem
      #   * Any files in app/views/advanced may need updates
      #   * Update this test with the correct versions

      expect(Blacklight::VERSION).to match(/^5\./)
      expect(BlacklightAdvancedSearch::VERSION).to match(/^5\.0\./)
    end
  end
end
