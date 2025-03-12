# frozen_string_literal: true

module SimulationRole
  def simulation_mode_on?
    !original_role.nil?
  end

  def switch_off_simulate_mode!
    return if original_role.nil?
    update(role: original_role, original_role: nil)
  end
end
