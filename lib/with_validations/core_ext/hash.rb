# encoding: utf-8

class Hash

  # Removes `*keys` from self.
  # @note (see #slice)
  # @return [Hash] self with `*keys` removed.
  def delete_keys!(*keys)
    keys.each do |key|
      self.delete(key)
    end
  end


  # Creates a sub-hash from `self` with the keys from `*keys`.
  # @note keys in `*keys` not present in `self` are silently ignored.
  # @return [Hash] a copy of `self`.
  def slice(*keys)
    self.select { |k,v| keys.include?(k) }
  end
end

