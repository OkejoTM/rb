class TextModerator
  # Удалять контакты из описания при наличии
  def remove_censored_words(text)
    return if text.blank?

    CensoredWord.all.select do |word|
      matcher =
          if word.regexp?
            Regexp.new(word.substitute)
          else
            word.substitute
          end
      text.gsub!(matcher, '')
    end

    text
  end
end
