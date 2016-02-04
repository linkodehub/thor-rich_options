# -*-mode: ruby; coding: utf-8 -*-

require 'thor'
require 'thor/rich_options/base'
require 'thor/rich_options/command'
require 'thor/rich_options/at_least_one'
require 'thor/rich_options/exclusive'

class Thor
  class << self
    include Thor::RichOptions::AtLeastOne
    include Thor::RichOptions::Exclusive
    
    # Prints help information for the given command.
    #
    # ==== Parameters
    # shell<Thor::Shell>
    # command_name<String>
    #
    def command_help(shell, command_name)
      meth = normalize_command_name(command_name)
      command = all_commands[meth]
      handle_no_command_error(meth) unless command

      shell.say "Usage:"
      shell.say "  #{banner(command)}"
      shell.say
      class_options_help(shell, nil => command.options.map { |_, o| o })
      print_exclusive_options(shell, command)
      print_at_least_one_required_options(shell, command)

      if command.long_description
        shell.say "Description:"
        shell.print_wrapped(command.long_description, :indent => 2)
      else
        shell.say command.description
      end
    end
    # Prints help information for this class.
    #
    # ==== Parameters
    # shell<Thor::Shell>
    #
    def help(shell, subcommand = false)
      list = printable_commands(true, subcommand)
      Thor::Util.thor_classes_in(self).each do |klass|
        list += klass.printable_commands(false)
      end
      list.sort! { |a, b| a[0] <=> b[0] }

      if defined?(@package_name) && @package_name
        shell.say "#{@package_name} commands:"
      else
        shell.say "Commands:"
      end

      shell.print_table(list, :indent => 2, :truncate => true)
      shell.say
      class_options_help(shell)
      print_exclusive_options(shell)
      print_at_least_one_required_options(shell)
    end
    def create_command(meth) #:nodoc:
      @usage ||= nil
      @desc ||= nil
      @long_desc ||= nil
      @disable_class_options ||= nil

      if @usage && @desc
        base_class = @hide ? Thor::HiddenCommand : Thor::Command
        relations = {:exclusive_option_names => method_exclusive_option_names,
          :at_least_one_option_names => method_at_least_one_option_names}
        commands[meth] = base_class.new(meth, @desc, @long_desc, @usage, method_options, @disable_class_options, relations)
        @usage, @desc, @long_desc, @method_options, @hide, @disable_class_options = nil
        @method_exclusive_option_names, @method_at_least_one_option_names = nil
        true
      elsif all_commands[meth] || meth == "method_missing"
        true
      else
        puts "[WARNING] Attempted to create command #{meth.inspect} without usage or description. " <<
             "Call desc if you want this method to be available as command or declare it inside a " <<
             "no_commands{} block. Invoked from #{caller[1].inspect}."
        false
      end
    end

  end
end
