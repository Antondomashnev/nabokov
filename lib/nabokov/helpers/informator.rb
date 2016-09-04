require "cork"

module Nabokov
  # This class is heavily based on the Interviewer class from the Danger gem
  # The original link is https://github.com/danger/danger/blob/master/lib/danger/commands/init_helpers/interviewer.rb
  class Informator
    attr_accessor :no_waiting, :ui

    def initialize(cork_board, verbose = false)
      @ui = cork_board
      @verbose = verbose
    end

    def show_prompt
      ui.print("> ".bold.green)
    end

    def say(message)
      ui.puts(message) if @verbose
    end

    def inform(message)
      ui.puts(message.green)
    end

    def important(message)
      i = message.length + 8
      inform("-" * i)
      inform("--- " + message + " ---")
      inform("-" * i)
    end

    def warn(message)
      ui.puts(message.yellow)
    end

    def error(message)
      ui.puts(message.red)
    end

    def wait_for_return
      STDOUT.flush
      STDIN.gets unless @no_waiting
      ui.puts
    end

    def ask_with_answers(question, possible_answers)
      ui.print("\n#{question}? [")

      print_info = proc do
        possible_answers.each_with_index do |answer, i|
          the_answer = i.zero? ? answer.underline : answer
          ui.print " " + the_answer
          ui.print(" /") if i != possible_answers.length - 1
        end
        ui.print " ]\n"
      end
      print_info.call

      answer = ""

      loop do
        show_prompt
        answer = @no_waiting ? possible_answers[0].downcase : STDIN.gets.downcase.chomp

        answer = "yes" if answer == "y"
        answer = "no" if answer == "n"

        # default to first answer
        if answer == ""
          answer = possible_answers[0].downcase
          ui.puts "Using: " + answer.yellow
        end

        break if possible_answers.map(&:downcase).include? answer

        ui.print "\nPossible answers are ["
        print_info.call
      end

      answer
    end
  end
end
