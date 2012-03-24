# encoding: UTF-8
require 'spec_helper'

describe "helpers" do
  it "OKCupid.strip removs funky lead and trailing white space" do
    OKCupid.strip(" Today – 2:40am ").should == "Today – 2:40am"
  end
end