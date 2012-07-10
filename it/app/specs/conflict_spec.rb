require 'minitest/spec'
require 'minitest/autorun'
require 'test_rest_client'

describe 'conflict' do

  it 'cycles a regular resource' do
    subject = TestRestClient.new(:car, 'cars')
    size = subject.size
    c = subject.create('color' => 'red')
    
    subject.size.must_equal(size + 1)
    c['id'].wont_be_nil
    c['created_at'].wont_be_nil
    c['updated_at'].wont_be_nil

    c['color'] = 'blue'
    cc = subject.update(c)

    cc['updated_at'].wont_equal c['updated_at']

    c['color'] = 'yellow'
    ccc = nil
    begin
      cc = subject.update(c)
    rescue RestClient::Conflict
      cc['color'] = 'yellow'
      ccc = subject.update(cc)
    end
    ccc['updated_at'].wont_equal c['updated_at']
    ccc['updated_at'].wont_equal cc['updated_at']
    
    first = subject.all.first['car']
    first['id'].wont_be_nil
    first['updated_at'].wont_be_nil

    begin
      subject.delete(c)
    rescue RestClient::Conflict
      subject.delete(ccc)
    end

    subject.size.must_equal size
  end

  it 'cycles a readonly resource' do
    subject = TestRestClient.new(:car_readonly, 'car_readonlies')

    all = subject.all
    all.size.must_equal 1

    first = all.first['car_readonly']
    first['id'].wont_be_nil
    first['updated_at'].wont_be_nil

    begin
      subject.create('color' => 'red')
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end

    first['color'] = 'blue'
    begin
      subject.update(first)
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end

    begin
      subject.delete(first)
      raise 'expected exception'
    rescue RestClient::ResourceNotFound
    end
  end

  it 'cycles a singleton resource' do 
    subject = TestRestClient.new(:car_singleton, 'car_singleton')
    c = subject.retrieve
    c['id'].must_be_nil
    c['created_at'].wont_be_nil
    c['updated_at'].wont_be_nil

    c['color'] = 'green'
    cc = subject.update(c)

    cc['updated_at'].wont_equal c['updated_at']

    c['color'] = 'yellow'
    ccc = nil
    begin
      cc = subject.update(c)
    rescue RestClient::Conflict
      cc['color'] = 'yellow'
      ccc = subject.update(cc)
    end

    ccc['updated_at'].wont_equal cc['updated_at']

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
    subject = TestRestClient.new(:car_readonly_singleton, 'car_readonly_singleton')
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
