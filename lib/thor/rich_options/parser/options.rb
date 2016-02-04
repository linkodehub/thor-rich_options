# -*-mode: ruby; coding: utf-8 -*-
require 'thor/parser/options'
require 'thor/rich_options/error'

class Thor
  class Options

    # Takes a hash of Thor::Option and a hash with defaults.
    #
    # If +stop_on_unknown+ is true, #parse will stop as soon as it encounters
    # an unknown option or a regular argument.
    def initialize(hash_options = {}, defaults = {}, stop_on_unknown = false, relations = {})
      @stop_on_unknown = stop_on_unknown
      @exclusives = (relations[:exclusive_option_names] || []).select{|array| !array.empty?}
      @at_least_ones = (relations[:at_least_one_option_names] || []).select{|array| !array.empty?}
      options = hash_options.values
      super(options)

      # Add defaults
      defaults.each do |key, value|
        @assigns[key.to_s] = value
        @non_assigned_required.delete(hash_options[key])
      end

      @shorts, @switches, @extra = {}, {}, []

      options.each do |option|
        @switches[option.switch_name] = option

        option.aliases.each do |short|
          name = short.to_s.sub(/^(?!\-)/, "-")
          @shorts[name] ||= option.switch_name
        end
      end
    end
    
    def parse(args) # rubocop:disable MethodLength
      @pile = args.dup
      @parsing_options = true

      while peek
        if parsing_options?
          match, is_switch = current_is_switch?
          shifted = shift

          if is_switch
            case shifted
            when SHORT_SQ_RE
              unshift($1.split("").map { |f| "-#{f}" })
              next
            when EQ_RE, SHORT_NUM
              unshift($2)
              switch = $1
            when LONG_RE, SHORT_RE
              switch = $1
            end

            switch = normalize_switch(switch)
            option = switch_option(switch)
            @assigns[option.human_name] = parse_peek(switch, option)
          elsif @stop_on_unknown
            @parsing_options = false
            @extra << shifted
            @extra << shift while peek
            break
          elsif match
            @extra << shifted
            @extra << shift while peek && peek !~ /^-/
          else
            @extra << shifted
          end
        else
          @extra << shift
        end
      end

      check_requirement!
      check_exclusive!
      check_at_least_one!

      assigns = Thor::CoreExt::HashWithIndifferentAccess.new(@assigns)
      assigns.freeze
      assigns
    end

    def check_exclusive!
      opts = @assigns.keys
      # When option A and B are exclusive, if A and B are given at the same time,
      # the diffrence of argument array size will decrease.
      found = @exclusives.find{ |ex| (ex - opts).size < ex.size - 1 }
      if found
        names = names_to_switch_names(found & opts).map{|n| "'#{n}'"}
        class_name = self.class.name.split("::").last.downcase
        fail ExclusiveArgumentError, "Found exclusive #{class_name} #{names.join(", ")}"
      end
    end
    def check_at_least_one!
      opts = @assigns.keys
      # When at least one is required of the options A and B,
      # if the both options were not given, none? would be true.
      found = @at_least_ones.find{ |one_reqs| one_reqs.none?{ |o| opts.include? o} }
      if found
        names = names_to_switch_names(found).map{|n| "'#{n}'"}
        class_name = self.class.name.split("::").last.downcase
        fail AtLeastOneRequiredArgumentError, "Not found at least one of required #{class_name} #{names.join(", ")}"
      end
    end

    protected
    # Option names changes to swith name or human name
    def names_to_switch_names(names = [])
      @switches.map do |_, o|
        if names.include? o.name
          o.respond_to?(:switch_name) ? o.switch_name : o.human_name
        else
          nil
        end
      end.compact
    end
  end
end
