class Parser::Operation::Base
  include Dry::Transaction
  extend Messegable

  # Шаг завершающий операцию и сохраняющий данные в БД
  # @param [Hash] attributes
  def save(attributes)
    raise NotImplementedError
  end

  protected

    # локали, которые поддерживаются моделями
    # @return [Array<Symbol>]
    def locales
      %i[en ru]
    end

    # Класс модели, для которой проводится операция
    def subject_class
      raise NotImplementedError
    end

    # Разрешенные параметры для сохранения записи
    def permitted_params(attributes)
      raise NotImplementedError
    end

    # Метод обрабатывающий Операцию. Может принять блок, чтобы дополнительно обработать результаты вызова операции
    # @param [Object] class_name Класс операции
    # @param [Array<Symbol>] result_keys массив ключей, который будут выбраны из результата и возвращены
    # @param [Hash] params параметры передаваемые в операцию. В случае провала операции, будут возвращены
    # @return [Hash]
    def handle_monad(class_name, result_keys, **params)
      class_name.new.call(params) do |m|
        m.success do |result|
          result.slice(*result_keys)
        end

        yield(m) if block_given?

        m.failure do
          params.slice(*result_keys)
        end
      end
    end
end
