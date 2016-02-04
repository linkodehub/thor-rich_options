require "thor/command"
require "thor/rich_options/command"
require "thor/rich_options/parser/options"


class Thor
  module Base


    # It receives arguments in an Array and two hashes, one for options and
    # other for configuration.
    #
    # Notice that it does not check if all required arguments were supplied.
    # It should be done by the parser.
    #
    # ==== Parameters
    # args<Array[Object]>:: An array of objects. The objects are applied to their
    #                       respective accessors declared with <tt>argument</tt>.
    #
    # options<Hash>:: An options hash that will be available as self.options.
    #                 The hash given is converted to a hash with indifferent
    #                 access, magic predicates (options.skip?) and then frozen.
    #
    # config<Hash>:: Configuration for this Thor class.
    #
    def initialize(args = [], local_options = {}, config = {}) # rubocop:disable MethodLength
      parse_options = config[:current_command] && config[:current_command].disable_class_options ? {} : self.class.class_options

      # The start method splits inbound arguments at the first argument
      # that looks like an option (starts with - or --). It then calls
      # new, passing in the two halves of the arguments Array as the
      # first two parameters.

      command_options = config.delete(:command_options) # hook for start
      parse_options = parse_options.merge(command_options) if command_options
      if local_options.is_a?(Array)
        array_options, hash_options = local_options, {}
      else
        # Handle the case where the class was explicitly instantiated
        # with pre-parsed options.
        array_options, hash_options = [], local_options
      end

      # Let Thor::Options parse the options first, so it can remove
      # declared options from the array. This will leave us with
      # a list of arguments that weren't declared.
      current_command = config[:current_command]
      stop_on_unknown = self.class.stop_on_unknown_option? current_command

      # Give a relation of options.
      # After parsing, Thor::Options check whether right relations are kept
      relations = {:exclusive_option_names => [], :at_least_one_option_names => []}
      unless current_command.nil? or current_command.options_relation.nil?
        relations = current_command.options_relation
      end

      self.class.class_exclusive_option_names.map{ |n| relations[:exclusive_option_names] << n}
      self.class.class_at_least_one_option_names.map{ |n| relations[:at_least_one_option_names] << n}

      opts = Thor::Options.new(parse_options, hash_options, stop_on_unknown, relations)

      self.options = opts.parse(array_options)
      self.options = config[:class_options].merge(options) if config[:class_options]

      # If unknown options are disallowed, make sure that none of the
      # remaining arguments looks like an option.
      opts.check_unknown! if self.class.check_unknown_options?(config)

      # Add the remaining arguments from the options parser to the
      # arguments passed in to initialize. Then remove any positional
      # arguments declared using #argument (this is primarily used
      # by Thor::Group). Tis will leave us with the remaining
      # positional arguments.
      to_parse  = args
      to_parse += opts.remaining unless self.class.strict_args_position?(config)

      thor_args = Thor::Arguments.new(self.class.arguments)
      thor_args.parse(to_parse).each { |k, v| __send__("#{k}=", v) }
      @args = thor_args.remaining
    end

    module ClassMethods
      # Returns this class exclusive options array set, looking up in the ancestors chain.
      #
      # ==== Rturns
      # Array[Array[Thor::Option.name]]
      #
      def class_exclusive_option_names
        @class_exclusive_option_names ||= from_superclass(:class_exclusive_option_names, [])
      end

      # Returns this class at least one of required options array set, looking up in the ancestors chain.
      #
      # ==== Rturns
      # Array[Array[Thor::Option.name]]
      #
      def class_at_least_one_option_names
        @class_at_least_one_option_names ||= from_superclass(:class_at_least_one_option_names, [])
      end


      # Adds and declareds option group for exclusive options in the
      # block and arguments. You can declare options as the outside of the block.
      #
      # ==== Parameters
      # Array[Thor::Option.name]
      #
      # ==== Examples
      #
      #   class_exclusive do
      #     class_option :one
      #     class_option :two
      #    end
      #
      # Or
      #
      #   class_option :one
      #   class_option :two
      #   class_exclusive :one, :two
      #
      # If you give "--one" and "--two" at the same time.
      # ExclusiveArgumentsError will be raised.
      #
      def class_exclusive(*args, &block)
        register_options_relation_for(:class_options,
                                      :class_exclusive_option_names, *args, &block)
      end

      # Adds and declareds option group for required at least one of options in the
      # block and arguments. You can declare options as the outside of the block.
      #
      # ==== Examples
      #
      #   class_at_least_one do
      #     class_option :one
      #     class_option :two
      #    end
      #
      # Or
      #
      #   class_option :one
      #   class_option :two
      #   class_at_least_one :one, :two
      #
      # If you do not give "--one" and "--two".
      # AtLeastOneRequiredArgumentError will be raised.
      # You can use class_at_least_one and class_exclusive at the same time.
      #
      #    class_exclusive do
      #      class_at_least_one do
      #        class_option :one
      #        class_option :two
      #      end
      #    end
      #
      # Then it is required either only one of "--one" or "--two".
      #
      def class_at_least_one(*args, &block)
        register_options_relation_for(:class_options,
                                      :class_at_least_one_option_names, *args, &block)
      end


    protected

      # Register a relation of options for target(method_option/class_option)
      # by args and block.
      def register_options_relation_for( target, relation, *args, &block)
        opt = args.pop if args.last.is_a? Hash
        opt ||= {}
        names = args.map{ |arg| arg.to_s }
        names += built_option_names(target, opt, &block) if block_given?
        command_scope_member(relation, opt) << names
      end

      # Get target(method_options or class_options) options
      # of before and after by block evaluation.
      def built_option_names(target, opt = {}, &block)
        before = command_scope_member(target, opt).map{ |k,v| v.name }
        instance_eval(&block)
        after  = command_scope_member(target, opt).map{ |k,v| v.name }
        after - before
      end

      # Get command scope member by name.
      def command_scope_member( name, options = {} ) #:nodoc:
        if options[:for]
          find_and_refresh_command(options[:for]).send(name)
        else
          send( name )
        end
      end
    end
  end
end
