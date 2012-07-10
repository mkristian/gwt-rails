require 'minitest/spec'
require 'minitest/autorun'
require 'test_rest_client'

describe 'serialize' do

  it 'loads a regular resource' do
    subject = TestRestClient.new(:car, 'cars')

    c = subject.create('color' => 'red')

    first = subject.all.first['car']
    first['id'].wont_be_nil
    first['created_at'].must_be_nil

    f = subject.retrieve(first)
    f['created_at'].wont_be_nil

    # single retrieve is complete
    first.each do |k,v|
      f[k].must_equal v
    end
    f.each do |k,v|
      v.wont_be_nil
    end

    # keys contains timestamps
    (f.keys | ['created_at','updated_at']).must_equal f.keys
    
    subject.delete(c)
  end

  it 'cycles a readonly resource' do
    subject = TestRestClient.new(:car_readonly, 'car_readonlies')

    first = subject.all.first['car_readonly']
    first['id'].wont_be_nil
    first['created_at'].must_be_nil
    f = subject.retrieve(first)
    f['created_at'].wont_be_nil

    # single retrieve is complete
    first.each do |k,v|
      f[k].must_equal v
    end
    f.each do |k,v|
      v.wont_be_nil
    end

    # keys contains timestamps
    (f.keys | ['created_at','updated_at']).must_equal f.keys
  end
end
