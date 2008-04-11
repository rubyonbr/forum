class String  
  def utf8_to_iso88591  
    array_utf8 = self.unpack('U*')  
    array_enc = []  
    array_utf8.each do |num|  
      if num <= 0xFF  
        array_enc << num  
      else  
        array_enc.concat "&\#\#{num};".unpack('C*')  
      end  
    end  
    array_enc.pack('C*')  
  end
    
  def iso88591_to_utf8  
    self.unpack('C*').pack('U*')  
  end  
end  