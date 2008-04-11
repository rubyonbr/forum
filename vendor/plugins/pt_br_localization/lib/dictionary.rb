class String
   def capitalize?
     self =~ /^[A-Z1-9][a-z1-9\W]*/
   end

   def upcase?
     self =~ /[A-Z1-9\W]+/
   end
end

class Dictionary

  @@dict = {
    'name' => 'nome',
    'names' => 'nomes',
    'description' => 'descrição',
    'descriptions' => 'descrições',
    'number' => 'número',
    'numbers' => 'números',
    'type' => 'tipo',
    'types' => 'tipos',
    'status' => 'status',
    'statuses' => 'status',
    'date' => 'data',
    'user' => 'usuário',
    'password' => 'senha',
    'login' => 'login',
    'indice' => 'indíce',
    'create' => 'criar',
    'update' => 'atualizar',
    'display name' => 'nome de exibição',
    'body' => 'corpo',
    'title' => 'título',
    'topic' => 'tópico'
  }

  def self.translate(key)
    key = key.to_s
    return "" if key.nil? 
    result = @@dict[key]
    result = @@dict[key.downcase] if result.nil? && @@dict[key.downcase]
    result = @@dict[key.downcase.gsub(" ", "_")] if result.nil? && @@dict[key.downcase.gsub(" ", "_")]
    
    result.capitalize! if result && key.capitalize?
    #result.upcase! if result && key.upcase?
    
    result = key if result.nil?
    result
  end
end
