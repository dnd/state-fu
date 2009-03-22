require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe Zen::Event do
  include MySpecHelper

  describe "When there is an empty koan" do
    before do
      reset!
      make_pristine_class 'Klass'
      Klass.koan() { }
    end

    it "should ..."

    it "should be created given valid arguments"

    describe "from()" do
    end

    describe "to()" do
    end

    describe "methods" do
      describe 'origin_names' do
      end

      describe 'target_names' do
      end

      describe 'to?' do
      end

      describe 'from?' do
      end

      describe 'from *args' do
      end

      describe 'to *args' do
      end

      describe 'origin=' do
      end

      describe 'target=' do
      end

      describe 'complete?' do
      end

      describe 'static?' do
      end

      describe 'simple?' do
      end

      describe 'dynamic?' do
      end

    end

    describe "An event with no origin / target" do

    end

    describe "An event with single origin & target" do

    end

    describe "An event with multiple origin & target" do
    end

  end
end
