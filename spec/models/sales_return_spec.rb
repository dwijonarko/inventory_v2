require File.dirname(__FILE__) + '/../spec_helper'

describe SalesReturn do
  it "should be valid" do
    SalesReturn.new.should be_valid
  end
end
