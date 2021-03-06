require 'oxblood/commands/hashes'

RSpec.describe Oxblood::Commands::Hashes do
  include_context 'test session'

  describe '#hdel' do
    it 'existing field' do
      connection.run_command(:HSET, 'myhash', 'field1', 'foo')
      expect(subject.hdel(:myhash, 'field1')).to eq(1)
    end

    it 'nonexistent field' do
      connection.run_command(:HSET, 'myhash', 'field1', 'foo')
      expect(subject.hdel(:myhash, 'field2')).to eq(0)
    end

    it 'nonexistent key' do
      expect(subject.hdel(:nonexistentkey, 'field')).to eq(0)
    end

    it 'multiple field' do
      connection.run_command(:HMSET, 'myhash', 'f1', 1, 'f2', 2, 'f3', 3)
      expect(subject.hdel(:myhash, ['f0', 'f1', 'f2'])).to eq(2)
    end
  end

  describe '#hexists' do
    it 'existing field' do
      connection.run_command(:HSET, 'myhash', 'field1', 'foo')
      expect(subject.hexists(:myhash, 'field1')).to eq(1)
    end

    it 'nonexistent field' do
      connection.run_command(:HSET, 'myhash', 'field1', 'foo')
      expect(subject.hexists(:myhash, 'field2')).to eq(0)
    end

    it 'nonexistent key' do
      expect(subject.hexists(:nonexistentkey, 'field')).to eq(0)
    end
  end

  describe '#hget' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'foo')

      expect(subject.hget('myhash', 'f1')).to eq('foo')
      expect(subject.hget('myhash', 'f2')).to be_nil
      expect(subject.hget('typohash', 'f1')).to be_nil
    end
  end

  describe '#hgetall' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      expect(subject.hgetall('myhash')).to eq(%w(f1 Hello f2 World))
    end
  end

  describe '#hincrby' do
    it 'existing field' do
      connection.run_command(:HSET, 'myhash', 'field', 5)

      expect(subject.hincrby('myhash', 'field', 1)).to eq(6)
      expect(subject.hincrby('myhash', 'field', -1)).to eq(5)
      expect(subject.hincrby('myhash', 'field', -10)).to eq(-5)
    end

    it 'nonexistent key' do
      expect(subject.hincrby('myhash', 'field', 5)).to eq(5)
    end

    it 'nonexistent field' do
      connection.run_command(:HSET, 'myhash', 'otherfield', 5)

      expect(subject.hincrby('myhash', 'field', 5)).to eq(5)
    end
  end

  describe '#hincrbyfloat' do
    it 'existing field' do
      connection.run_command(:HSET, 'myhash', 'field1', 10.50)
      connection.run_command(:HSET, 'myhash', 'field2', '5.0e3')

      expect(subject.hincrbyfloat('myhash', 'field1', 0.1)).to eq('10.6')
      expect(subject.hincrbyfloat('myhash', 'field2', '2.0e2')).to eq('5200')
    end

    it 'nonexistent key' do
      expect(subject.hincrbyfloat('myhash', 'field', 5.0)).to eq('5')
    end

    it 'nonexistent field' do
      connection.run_command(:HSET, 'myhash', 'otherfield', 5)

      expect(subject.hincrbyfloat('myhash', 'field', 5.0)).to eq('5')
    end

    it 'field value is not parsable as a double precision' do
      connection.run_command(:HSET, 'myhash', 'field', 'asd')
      resp = subject.hincrbyfloat('myhash', 'field', 5.0)

      expect(resp).to be_a(Oxblood::Protocol::RError)
    end
  end

  describe '#hkeys' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      expect(subject.hkeys('myhash')).to contain_exactly('f1', 'f2')
    end

    it 'nonexistent key' do
      expect(subject.hkeys('myhash')).to eq([])
    end
  end

  describe '#hlen' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      expect(subject.hlen('myhash')).to eq(2)
    end

    it 'nonexistent key' do
      expect(subject.hlen('myhash')).to eq(0)
    end
  end

  describe '#hmget' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      result = ['Hello', 'World', nil]
      expect(subject.hmget('myhash', 'f1', 'f2', 'nofield')).to eq(result)
    end
  end

  describe '#hmset' do
    specify do
      expect(subject.hmset(:myhash, 'f1', 'Hello', 'f2', 'World')).to eq('OK')
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('Hello')
      expect(connection.run_command(:HGET, 'myhash', 'f2')).to eq('World')
    end
  end

  describe '#hset' do
    it 'new field' do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')

      expect(subject.hset('myhash', 'f2', 'World')).to eq(1)
      expect(connection.run_command(:HGET, 'myhash', 'f2')).to eq('World')
    end

    it 'nonexistent key' do
      expect(subject.hset('myhash', 'f1', 'Hello')).to eq(1)
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('Hello')
    end

    it 'updates existing field' do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')

      expect(subject.hset('myhash', 'f1', 'World')).to eq(0)
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('World')
    end
  end

  describe '#hsetnx' do
    it 'nonexistent key' do
      expect(subject.hsetnx('myhash', 'f1', 'Hello')).to eq(1)
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('Hello')
    end

    it 'new field' do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')

      expect(subject.hsetnx('myhash', 'f2', 'World')).to eq(1)
      expect(connection.run_command(:HGET, 'myhash', 'f2')).to eq('World')
    end

    it 'does not update existing field' do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')

      expect(subject.hsetnx('myhash', 'f1', 'World')).to eq(0)
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('Hello')
    end
  end

  describe '#hstrlen', if: server_newer_than('3.2.0') do
    specify do
      command = [:HMSET, 'myhash', 'f1', 'HelloWorld', 'f2', '99', 'f3', '-256']
      connection.run_command(*command)

      expect(subject.hstrlen('myhash', 'f1')).to eq(10)
      expect(subject.hstrlen('myhash', 'f2')).to eq(2)
      expect(subject.hstrlen('myhash', 'f3')).to eq(4)
    end

    it 'key does not exists' do
      expect(subject.hstrlen('myhash', 'f1')).to eq(0)
    end

    it 'field does not exists' do
      connection.run_command([:HSET, 'myhash', 'f1', 'Hello'])

      expect(subject.hstrlen('myhash', 'f2')).to eq(0)
    end
  end

  describe '#hvals' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      expect(subject.hvals('myhash')).to contain_exactly('Hello', 'World')
    end

    it 'key does not exists' do
      expect(subject.hvals('myhash')).to match_array([])
    end
  end

  describe '#hscan' do
    specify do
      subject.run_command(:HMSET, :h, 'name', 'Jack', 'age', 33)

      response = subject.hscan(:h, 0)

      expect(response).to be_an(Array)
      expect(response.first).to eq('0')
      expect(response.last).to match_array(%w(name Jack age 33))
    end

    context 'options' do
      before do
        values = (0...20)
        keys = values.map { |n| n > 9 ? "z#{n}" : "t#{n}" }
        args = keys.zip(values).flatten.unshift(:HMSET, :h)
        subject.run_command(*args)
      end

      it 'MATCH' do
        response = subject.hscan(:h, 0, match: "*t*")

        expect(response).to be_an(Array)
        expect(response.last.each_slice(2).map(&:first)).to all(start_with('t'))
      end
    end
  end
end
