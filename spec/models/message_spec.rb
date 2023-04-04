# == Schema Information
#
# Table name: messages
#
#  id         :bigint           not null, primary key
#  chat_id    :bigint           not null
#  role       :string
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Message, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
