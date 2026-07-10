{% macro double_then_sum(number1: int, number2: int) %}
    {{ function('double_then_sum') }}({{ number1}}, {{ number2 }})
{% endmacro %}