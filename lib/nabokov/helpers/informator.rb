require "cork"

module Nabokov
  # This class is heavily based on the Interviewer class from the Danger gem
  # The original link is https://github.com/danger/danger/blob/master/lib/danger/commands/init_helpers/interviewer.rb
  class Informator
    attr_accessor :no_waiting, :ui

    def initialize(cork_board)
      @ui = cork_board
    end

    def show_prompt
      ui.print("> ".bold.green)
    end

    def say(message)
      ui.puts(message)
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
      print_possible_answers(possible_answers)
      answer = ""
      loop do
        show_prompt
        answer = read_answer(possible_answers)

        break if possible_answers.map(&:downcase).include? answer

        ui.print "\nPossible answers are ["
        print_possible_answers(possible_answers)
      end
      answer
    end

    private

    def read_answer(possible_answers)
      answer = @no_waiting ? possible_answers[0].downcase : STDIN.gets.downcase.chomp
      answer = "yes" if answer == "y"
      answer = "no" if answer == "n"

      # default to first answer
      if answer == ""
        answer = possible_answers[0].downcase
        ui.puts "Using: " + answer.yellow
      end
      answer
    end

    def print_possible_answers(possible_answers)
      possible_answers.each_with_index do |answer, i|
        the_answer = i.zero? ? answer.underline : answer
        ui.print " " + the_answer
        ui.print(" /") if i != possible_answers.length - 1
      end
      ui.print " ]\n"
    end
  end
end
