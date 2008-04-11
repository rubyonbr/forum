require File.join(File.dirname(__FILE__), 'dictionary')

module ActiveRecord
  class Errors
    begin
      @@default_error_messages.update( {
        :inclusion => "não está incluído na lista",
        :exclusion => "é reservado",
        :invalid => "é inválido",
        :confirmation => "não confere com a confirmação",
        :accepted  => "deve ser aceito",
        :empty => "não pode ser vazio",
        :blank => "não pode estar em branco",
        :too_long => "é muito grande (esperado %d caracteres)",
        :too_short => "é muito pequeno (esperado %d caracteres)",
        :wrong_length => "tem tamanho incorreto (esperado %d caracteres)",
        :taken => "já foi usado",
        :not_a_number => "não é um número",
      })
    end

    # Returns all the full error messages in an array.
    def full_messages
      full_messages = []

      @errors.each_key do |attr|
        @errors[attr].each do |msg|
          next if msg.nil?

          if attr == "base"
            full_messages << msg
          else
            full_messages << Dictionary.translate(@base.class.human_attribute_name(attr)) + " " + msg
          end
        end
      end

      return full_messages
    end    
  end
end

module ActionView #nodoc
  module Helpers
    module ActiveRecordHelper
      def error_messages_for(object_name, options = {})
        options = options.symbolize_keys
        object = instance_variable_get("@#{object_name}")
        unless object.errors.empty?
          begin_message = object.errors.count != 1 ? "erros impedem" : "erro impede" 
          content_tag("div",
            content_tag(
              options[:header_tag] || "h2",
              "#{object.errors.count} #{begin_message} que #{Dictionary.translate(object_name.to_s.gsub("_", " "))} seja salvo" 
            ) +
            content_tag("p", "Os seguintes campos apresentaram problemas:") +
            content_tag("ul",
              object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
              "id" => options[:id] || "errorExplanation",
              "class" => options[:class] || "errorExplanation"
          )
        end
      end
    end
  end
end




