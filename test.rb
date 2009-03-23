module OrderedHash
  def []( index )
    begin
      super( index )
    rescue TypeError
      self.detect do |i|
        i.first == index
      end[1] # if index.class ...
    end
  end

  def keys
    map(&:first)
  end

  def values
    map(&:last)
  end
end  # ArrayNameAccessor

h = [[:a,1],['b',2],[:c,3]].extend OrderedHash
h.keys      # => [:a, 'b', :c]
h[0]        # => [:a, 1]
h.values[0] # => 1
h[:a]       # => 1
