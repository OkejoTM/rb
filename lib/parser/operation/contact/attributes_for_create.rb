class Parser::Operation::Contact::AttributesForCreate < Parser::Operation::Contact::AttributesForUpdate
  map :get_attributes
  step :check_attributes
  map :add
  map :finish
end
