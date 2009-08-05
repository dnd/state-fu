module Optional
  attr_reader :options
  
  def []v
    options[v]
  end

  def []=v,k
    options[v]=k
  end
end