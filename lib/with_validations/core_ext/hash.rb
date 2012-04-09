# encoding: utf-8

class Hash
  # Creates a sub-hash from `self` with the keys from `keys`
  # @note keys in `keys` not present in `self` are silently ignored.
  # @return [Hash] a copy of `self`.
  def slice(*keys)
    self.select { |k,v| keys.include?(k) }
  end
end

