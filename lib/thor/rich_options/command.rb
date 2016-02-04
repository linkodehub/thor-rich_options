# -*-mode: ruby; coding: utf-8 -*-

class Thor
  class Command #< Struct.new(:name, :description, :long_description, :usage, :options, :disable_class_options, :options_relation)
    attr_accessor :options_relation, :disable_class_options
    def initialize(name, description, long_description, usage, options = nil, disable_class_options = false, options_relation = nil)
      super(name.to_s, description, long_description, usage, options || {})
      @disable_class_options = disable_class_options || false
      @options_relation = options_relation || {}
    end
    def initialize_copy(other) #:nodoc:
      super(other)
      self.options = other.options.dup if other.options
      self.options_relation = other.options_relation.dup if other.options_relation
    end

    def method_exclusive_option_names
      self.options_relation[:exclusive_option_names] || []
    end
    def method_at_least_one_option_names
      self.options_relation[:at_least_one_option_names] || []
    end
  end
end
