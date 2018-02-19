require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.shuffle[0,10]
    puts @letters.class
  end

  def score
    @letters = params[:letters]
    @word = params[:word]

    if !buitable?(@word, @letters)
      @message = "The word '#{@word}' can't be built out of the original grid #{@letters}"
      @score = 0
    elsif not_a_valid_english_word?(@word, @letters)
      @message = "The word '#{@word}' is valid according to the grid #{@letters}, but is
    not a valid English word"
    @score = 0
    else
      @message = "The word '#{@word}' is valid according to the grid #{@letters}
      and is an English word"
      @score = @word.size
    end
    session[:scores] = session[:scores].nil? ? 0 : session[:scores] + @score
    @total_score = session[:scores]
  end

  private

  def buitable?(word, letters)
    hash_word = to_hash(word.upcase.scan /\w/)
    hash_letters = to_hash(letters.scan /\w/)
    answer = true
    hash_word.each do |key, value|
      answer = answer && false if !hash_letters.key?(key) || hash_letters[key] < value
    end
    answer
  end

  def not_a_valid_english_word?(word, letters)
    buitable?(word, letters) && !english_word?(word)
  end

  def english_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
  response = open(url).read
  hash = JSON.parse(response)
  hash['found']
  end

  def to_hash(word_array)
    hash = {}
    word_array.each do |letter|
      hash[letter] = hash[letter] ? hash[letter] + 1 : 1
    end
    hash
  end
end

