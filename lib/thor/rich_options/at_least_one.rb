# -*-mode: ruby; coding: utf-8 -*-

class Thor
  module RichOptions
    module AtLeastOne
      # Returns this class at least one of required options array set.
      #
      # ==== Rturns
      # Array[Array[Thor::Option.name]]
      #
      def method_at_least_one_option_names
        @method_at_least_one_option_names ||=[]
      end

      # Adds and declareds option group for required at least one of options in the
      # block of arguments. You can declare options as the outside of the block.
      # If :for is given as option,
      # it allows you to change the options from a prvious defined command.
      #
      # ==== Parameters
      # Array[Thor::Option.name]
      # options<Hash>:: :for is applied for previous defined command.
      #
      # ==== Examples
      #
      #   at_least_one do
      #     option :one
      #     option :two
      #    end
      #
      # Or
      #
      #   option :one
      #   option :two
      #   at_least_one :one, :two
      #
      # If you do not give "--one" and "--two".
      # AtLeastOneRequiredArgumentError will be raised.
      #
      # You can use at_least_one and exclusive at the same time.
      #
      #    exclusive do
      #      at_least_one do
      #        option :one
      #        option :two
      #      end
      #    end
      #
      # Then it is required either only one of "--one" or "--two".
      #
      def method_at_least_one(*args, &block)
        register_options_relation_for(:method_options,
                                      :method_at_least_one_option_names, *args, &block)
      end
      alias_method :at_least_one, :method_at_least_one

      def print_at_least_one_required_options(shell, command = nil)
        opts = []
        opts = command.method_at_least_one_option_names unless command.nil?
        opts += class_at_least_one_option_names
        unless opts.empty?
          shell.say "Required At Least One:"
          shell.print_table(opts.map{ |ex| ex.map{ |e| "--#{e}"}}, :indent => 2 )
          shell.say
        end
      end
      
    end
  end
end
