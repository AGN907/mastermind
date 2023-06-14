# frozen_string_literal: true

# rubocop:disable Style/Documentation
module Mastermind
  class Game
    def initialize
      @code = build_code
      @turns = 12
      @player = Player.new
      @computer = Computer.new(self)
    end

    def start_game
      starting_message
    end

    def code_breaker # rubocop:disable Metrics/MethodLength
      loop do
        answer = gets_answer
        if correct?(answer)
          puts "Congratulations for winning! the secret code was #{@code}"
          return
        elsif turns_zero?
          puts "Game over! The code is #{@code.join}"
          return
        end
        puts "Hint: #{hints(answer)}\n\n"
      end
    end

    def code_maker
      @code = @player.make_secret_code
      loop do
        answer = @computer.break_code

        if correct?(answer)
          puts "The computer has won! The computer guess is #{answer.join} and The code is #{@code.join}"
          return
        elsif turns_zero?
          puts "Game over! The computer couldn't break your code! You're UNBEATABLE!"
          return
        end
        puts "Turn #{@turns}> Computer guess is (#{answer.join}) and hint is #{hints(answer)}"
        @turns -= 1
      end
    end

    def build_code
      (1..4).each_with_object([]) do |_, array|
        random_number = ((rand * 6) + 1).round.to_s
        array.push(random_number)
      end
    end

    def turns_zero?
      return true if @turns.zero?
    end

    def correct?(answer)
      return unless answer.length == 4

      @code == answer
    end

    # #return [String]
    # @param code [Array]
    # @param answer [String]
    def hints(answer, code = @code)
      sliced_code = code.slice(0..)

      hints = answer.map.with_index do |answer_ele, idx|
        next unless sliced_code.include?(answer_ele)

        hint = answer_ele == code[idx] ? 'O' : 'X'
        sliced_code.delete_at(sliced_code.index(answer_ele))

        hint
      end
      hints.join
    end

    def gets_answer
      puts "Turn #{@turns}> Type four digits (1-6)"
      @turns -= 1

      @player.give_answer
    end

    # @return String
    def starting_message
      puts 'Welcome to Mastermind'

      puts 'They are two roles'
      puts '1- Code Breaker. You must guess the secret code within 12 turns.'
      puts "2- Code Maker. You create the code and the Computer will try to guess it.\n\n"

      explain_clues
      gets_role
    end

    def explain_clues
      puts "'O' means there's a correct number on the correct place"
      puts "'X' means there's a correct number on the wrong place\n\n"
    end

    def gets_role
      puts 'Enter your choice: '

      while (role = gets.to_i)
        break if [1, 2].include?(role)
      end
      code_breaker if role == 1
      code_maker if role == 2
    end
  end

  # Class for Mastermind player
  class Player
    def give_answer
      while (answer = gets.chomp.chars)

        return answer if answer.length == 4

        puts 'Invalid input!'
      end
    end

    def make_secret_code
      puts 'Type the 4 digits secret code (1-6)'
      while (secret_code = gets.chomp.chars)
        return secret_code if secret_code.length == 4

        puts 'Invalid input!'
      end
    end
  end

  class Computer
    def initialize(game)
      @permutations = create_permutations
      @game = game
    end

    def guess_code
      return %w[1 1 1 1] if @permutations.length == 1296

      @permutations.first
    end

    def get_hints(answer)
      @game.hints(answer)
    end

    def break_code
      answer = guess_code
      guess_hint = get_hints(answer)

      return answer if guess_hint == 'OOOO'

      compare_hints(answer, guess_hint)
      answer
    end

    def compare_hints(last_guess, last_guess_hint)
      @permutations.each do |perma|
        perma_hint = @game.hints(last_guess, perma)

        next unless perma_hint != last_guess_hint

        delete_permutations(perma)
      end
    end

    def delete_permutations(array)
      @permutations.reject! { |item| item == array }
    end

    def create_permutations
      array = %w[1 2 3 4 5 6]
      array.repeated_permutation(4).to_a
    end
  end
end

include Mastermind
Game.new.start_game

# rubocop:enable Style/Documentation
