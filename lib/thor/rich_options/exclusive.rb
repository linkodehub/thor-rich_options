# -*-mode: ruby; coding: utf-8 -*-

class Thor
  module RichOptions
    module Exclusive
      # Returns this class exclusive options array set.
      #
      # ==== Rturns
      # Array[Array[Thor::Option.name]]
      #
      def method_exclusive_option_names
        @method_exclusive_option_names ||=[]
      end

      # Adds and declareds option group for exclusive options in the
      # block and arguments. You can declare options as the outside of the block.
      # If :for is given as option,
      # it allows you to change the options from a prvious defined command.
      #
      # ==== Parameters
      # Array[Thor::Option.name]
      # options<Hash>:: :for is applied for previous defined command.
      #
      # ==== Examples
      #
      #   exclusive do
      #     option :one
      #     option :two
      #    end
      #
      # Or
      #
      #   option :one
      #   option :two
      #   exclusive :one, :two
      #
      # If you give "--one" and "--two" at the same time.
      # ExclusiveArgumentsError will be raised.
      #
      def method_exclusive(*args, &block)
        register_options_relation_for(:method_options,
                                      :method_exclusive_option_names, *args, &block)
      end
      alias_method :exclusive, :method_exclusive

      def print_exclusive_options(shell, command = nil)
        opts = []
        opts  = command.method_exclusive_option_names unless command.nil?
        opts += class_exclusive_option_names
        unless opts.empty?
          shell.say "Exclusive Options:"
          shell.print_table(opts.map{ |ex| ex.map{ |e| "--#{e}"}}, :indent => 2 )
          shell.say
        end
      end
    end
  end
end
