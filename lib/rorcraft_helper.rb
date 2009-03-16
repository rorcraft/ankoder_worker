# Hash --------------------------------
 class Hash
    # Usage { :a => 1, :b => 2, :c => 3}.except(:a) -> { :b => 2, :c => 3}
    def except(*keys)
      self.reject { |k,v|
        keys.include? k.to_sym
      }
    end

    # Usage { :a => 1, :b => 2, :c => 3}.only(:a) -> {:a => 1}
    def only(*keys)
      self.dup.reject { |k,v|
        !keys.include? k.to_sym
      }
    end
    
    def recursive_merge(h)
        self.merge!(h) {|key, _old, _new| if _old.class == Hash then _old.recursive_merge(_new) else _new end  } 
    end

  end
