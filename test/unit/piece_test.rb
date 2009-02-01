require File.dirname(__FILE__) + '/../test_helper'

class PieceTest < ActiveSupport::TestCase

  should_belong_to :tracker

  ############
  context "The class Piece" do
    setup do
      # on vacation
      i18n_file = File.dirname(__FILE__) + '/../files/i18n.html'
      @i18n_data = IO.read(i18n_file)
    end

    should "fetch a title." do
       uri = "http://better-idea.org"
       assert_equal "matthias lüdtke", Piece.fetch_title(uri)
    end
 
  end

end
