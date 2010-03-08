require File.dirname(__FILE__) + '/../spec_helper'

describe Item do
  it "should be valid given valid attributes" do
    Factory.build(:item).should be_valid
  end

  it 'should  invalid without code' do
    Factory.build(:item, :code => nil).should_not be_valid
  end

  it 'should invalid without name' do
    Factory.build(:item, :name => nil).should_not be_valid
  end

  it 'can have the same code between companies' do
    company1 = Factory(:company)
    company2 = Factory(:company)
    item1 = Factory(:item, :company_id => company1.id)
    item2 = Factory.build(:item, :code => item1.code, :company_id => company2.id)
    item2.should be_valid
  end

  it 'should have unique code within a company' do
    company = Factory(:company)
    item1 = Factory(:item, :company_id => company.id)
    Factory.build(:item, :company_id => company.id, :code => item1.code).should_not be_valid
  end

  it 'should belongs to a company' do
    company = Factory(:company)
    Factory(:item, :company_id => company.id).should be_valid
  end
end
