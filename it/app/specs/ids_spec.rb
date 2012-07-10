require 'minitest/spec'
require 'minitest/autorun'
require 'test_rest_client'

describe 'ids' do

  it 'cycles a regular resource' do
    subject = TestRestClient.new(:car, :cars)
    size = subject.size
    c = subject.create('color' => 'red')
    
    subject.size.must_equal(size + 1)
    c['id'].wont_be_nil
    c['created_at'].must_be_nil
    c['updated_at'].must_be_nil

    c['color'] = 'blue'
    cc = subject.update(c)

    c['color'] = 'yellow'
    ccc = subject.update(c)
 
    cccc = subject.all.first['car']
    cccc['id'].wont_be_nil
    cccc['created_at'].must_be_nil
    cccc['updated_at'].must_be_nil
   
    subject.delete(c)

    subject.size.must_equal size
  end

  it 'cycles a readonly resource' do
    subject = TestRestClient.new(:car_readonly, :car_readonlies)

    all = subject.all
    all.size.must_equal 1

    c = all.first['car_readonly']
    c['id'].wont_be_nil
    c['created_at'].must_be_nil
    c['updated_at'].must_be_nil

    cc = subject.retrieve(c)
    cc['id'].must_equal c['id']
    cc['created_at'].must_be_nil
    cc['updated_at'].must_be_nil

    # single retrieve is complete
    c.each do |k,v|
      cc[k].must_equal v
    end
    
    cc.keys.must_equal c.keys
    
    begin
      subject.create('color' => 'red')
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end

    cc['color'] = 'blue'
    begin
      subject.update(cc)
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end

    begin
      subject.delete(cc)
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end
  end

  it 'cycles a singleton resource' do 
    subject = TestRestClient.new(:car_singleton)
    c = subject.retrieve
    c['id'].must_be_nil
    c['created_at'].must_be_nil
    c['updated_at'].must_be_nil

    c['color'] = 'blue'
    cc = subject.update(c)

    c['color'] = 'yellow'
    ccc = subject.update(c)

    begin
      subject.create('color' => 'red')
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end

    begin
      subject.delete(c)
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end
  end

  it 'cycles a readonly singleton resource' do 
    subject = TestRestClient.new(:car_readonly_singleton)
    c = subject.retrieve
    c['id'].must_be_nil
    c['created_at'].must_be_nil
    c['updated_at'].must_be_nil
    
    begin
      subject.create('color' => 'red')
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end

    c['color'] = 'blue'
    begin
      subject.update(c)
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end

    begin
      subject.delete(c)
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end
  end
end
