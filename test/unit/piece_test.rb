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

       String.stubs(:foo).returns(10)
       assert_equal 10, String.foo

       Net.stubs(:foo).returns(42)
       assert_equal 42, Net.foo

       Net::HTTP.stubs(:foo).returns(4711)
       assert_equal 4711, Net::HTTP.foo

       Net::HTTP::Get.stubs(:foo).returns(666)
       assert_equal 666, Net::HTTP::Get.foo

#       uri = "http://better-idea.org"
#       assert_equal "Matthias Lüdtke", Piece.fetch_title(uri)
    end
 
  end

end
