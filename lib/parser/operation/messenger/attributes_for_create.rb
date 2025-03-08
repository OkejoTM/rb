class Parser::Operation::Messenger::AttributesForCreate < Parser::Operation::Messenger::AttributesForUpdate
  map :get_attributes
  step :check_attributes
  map :add_not_existed
  map :finish
end
