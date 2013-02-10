require 'spec_helper'

describe Bill do
  let!(:bill) { FactoryGirl.build(:bill) }

  it 'compares equal attributes of two bills' do
    bill_cloned = bill.clone
    (bill === bill_cloned).should be_true
    (bill.eql? bill_cloned).should be_false
  end

  it 'compares different attributes of two bills' do
    bill_different_id = FactoryGirl.build(:bill, id: 10)
    (bill_different_id === bill).should be_false
  end

  it 'saves a bill' do
    expect { bill.save }.to change { Bill.count }.by(1)
  end
  
  it 'finds a bill by id' do
    bill.save
    bill_found = Bill.find(bill.id)
    (bill === bill_found).should be_true
  end

  it 'counts the amount of bills' do
    Bill.count.should == 0
    bill.save
    Bill.count.should == 1
  end

  after do
    REDIS.del 'bills'
    REDIS.keys('bills:*').each { |key| REDIS.del key }
    REDIS.del 'ids:bills'
  end
end
