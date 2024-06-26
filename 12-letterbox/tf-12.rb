raise 'Please assign an input file as ARGV[0]' if ARGV[0].nil?
raise 'Please assign an stop_words file as ARGV[1]' if ARGV[1].nil?

module Dispachable
    def dispatch(message)
        if self.class.private_method_defined?(message[0])
            self.send(*message)
        else
            raise StandardError.new("Message not understood #{message[0]}")
        end
    end
end

class DataStorageManager
    include Dispachable

    def initialize
        self.data = ''
    end

    private 

    attr_accessor :data

    def init(path_to_file)
        self.data = File.open(path_to_file).read.gsub(/[\W_]+/, ' ').downcase
    end

    def words
        data_str = self.data.split(' ')
    end
end

class StopWordManager
    include Dispachable

    def initialize
        self.stop_words = []
    end

    private 

    attr_accessor :stop_words

    def init(path_to_stop_words_file)
         self.stop_words = File.open(path_to_stop_words_file).read.split(',') + ('a'..'z').to_a
    end

    def stop_word?(word)
        self.stop_words.include?(word)
    end
end

class WordFrequencyManager
    include Dispachable

    def initialize
        self.word_freqs = Hash.new(0)
    end

    private

    attr_accessor :word_freqs

    def increment_count(word)
        self.word_freqs[word] += 1
    end

    def sorted
        self.word_freqs.to_a.sort_by.with_index { |v, i| [-v[1], i += 1] }
    end
end

class WordFrequencyController
    include Dispachable

    private 
    
    attr_accessor :storage_manager, :stop_word_manager, :word_freq_manager

    def init(path_to_file, path_to_stop_words_file)
        self.storage_manager = DataStorageManager.new
        self.stop_word_manager = StopWordManager.new
        self.word_freq_manager = WordFrequencyManager.new

        self.storage_manager.dispatch(['init', path_to_file])
        self.stop_word_manager.dispatch(['init', path_to_stop_words_file])
    end    

    def run
        self.storage_manager.dispatch(['words']).each do |word|
            if !self.stop_word_manager.dispatch(['stop_word?', word])
                self.word_freq_manager.dispatch(['increment_count', word])
            end
        end

        word_freqs = self.word_freq_manager.dispatch(['sorted'])
        word_freqs[0..24].each do |w, c|
            print("#{w} - #{c}\n")
        end
    end
end

wf_controller = WordFrequencyController.new
wf_controller.dispatch(['init', ARGV[0], ARGV[1]])
wf_controller.dispatch(['run'])