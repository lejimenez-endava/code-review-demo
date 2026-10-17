Order = Struct.new(:subtotal, :item_count)
Discount = Struct.new(:code, :type, :value)

class OrderDiscountCalculator
  class UnknownDiscountError < StandardError; end

  def initialize(order:, available_discounts:)
    @order = order
    @discounts_by_code = available_discounts.to_h { |discount| [discount.code, discount] }
  end

  def total_with_discounts(discount_codes)
    return @order.subtotal if discount_codes.empty?

    discount_codes.reduce(@order.subtotal) do |total, code|
      discount = @discounts_by_code[code]
      next total unless discount

      apply_discount(total, discount)
    end
  end

  private

  def apply_discount(total, discount)
    case discount.type
    when "percentage"
      total - (total * discount.value / 100.0)
    when "fixed"
      [total - discount.value, 0].max
    else
      raise UnknownDiscountError, "Unknown discount type: #{discount.type}"
    end
  end
end
