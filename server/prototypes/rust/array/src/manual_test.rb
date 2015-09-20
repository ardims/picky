require File.expand_path('../integration', __FILE__)

def mem
  GC.start
  puts `ps aux | grep #{Process.pid}`.split("\n").find { |s| s.match(/manual_test/) }
end

def timed
  t = Time.now
  yield
  p Time.now - t
end

TIMES = 10

def rust_ary
  ary = Rust::Array.new
  timed do
    TIMES.times do |i|
      ary << i
    end
  end
  ary.length
  p ary.size
  p [ary.first, ary.last]
end
def ruby_ary
  ary = Array.new
  timed do
    TIMES.times do |i|
      ary << i
    end
  end
  ary.length
  p ary.size
  p [ary.first, ary.last]
end

KEYS = ['abc', 'def', 'ghi', 'jkl', 'mno']
def rust_hash
  some_hash = Rust::Hash.new
  some_hash['test'] = Rust::Array.new
  p "Stored: #{some_hash['test']}"
  
  hash = Rust::Hash.new
  keys_size = KEYS.size
  timed do
    TIMES.times do |i|
      key = KEYS[i % keys_size]
      p [:hash_key, hash[key]]
      hash[key] ||= Rust::Array.new
      p [:hash_key, hash[key]]
      # hash[key] << i
    end
  end
  p [:rust_hash_length, hash.length]
  p [:rust_hash_size, hash.size]
  p hash['abc']
end
def ruby_hash
  hash = Hash.new
  keys_size = KEYS.size
  timed do
    TIMES.times do |i|
      key = KEYS[i % keys_size]
      hash[key] ||= Array.new
      hash[key] << i
    end
  end
  hash.length
  p hash.size
  p hash['abc']
end

# # Array
#
# puts `ps aux | head -1`
# mem
# rust_ary
# mem
# ruby_ary
# mem

# Hash

puts `ps aux | head -1`
mem
rust_hash
mem
ruby_hash
mem

# Combined
