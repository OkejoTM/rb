# == Schema Information
#
# Table name: censored_words
#
#  id              :bigint           not null, primary key
#  substitute      :string           not null
#  substitute_type :integer          default("text"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CensoredWord < ApplicationRecord
  WORD_TYPES = {
      regexp: 0,
      text: 1,
  }.freeze
  enum substitute_type: WORD_TYPES
end
