# test_pytest_validation.py

import pytest

# --- Basic Assertions ---

def test_true_is_true():
    """Validates that boolean True evaluates to True."""
    assert True is True

def test_false_is_false():
    """Validates that boolean False evaluates to False."""
    assert False is False

def test_none_is_none():
    """Validates that None evaluates to None."""
    assert None is None

def test_zero_is_zero():
    """Validates that the integer 0 evaluates to 0."""
    assert 0 == 0

# --- Arithmetic Operations ---

def test_addition():
    """Tests basic addition."""
    assert 1 + 1 == 2
    assert 5 + 0 == 5
    assert -2 + 3 == 1

def test_subtraction():
    """Tests basic subtraction."""
    assert 5 - 2 == 3
    assert 10 - 10 == 0
    assert 0 - 5 == -5

def test_multiplication():
    """Tests basic multiplication."""
    assert 2 * 3 == 6
    assert 7 * 0 == 0
    assert -4 * 2 == -8

def test_division():
    """Tests basic division with floats."""
    assert 10 / 2 == 5.0
    assert 7 / 2 == 3.5
    assert 1 / 3 == pytest.approx(0.3333333333333333) # Use pytest.approx for float comparisons

def test_integer_division():
    """Tests integer division."""
    assert 10 // 3 == 3
    assert 7 // 2 == 3

def test_modulo():
    """Tests the modulo operator."""
    assert 10 % 3 == 1
    assert 7 % 2 == 1
    assert 6 % 3 == 0

# --- String Operations ---

def test_string_concatenation():
    """Tests string concatenation."""
    assert "hello" + " " + "world" == "hello world"

def test_string_length():
    """Tests string length."""
    assert len("pytest") == 6
    assert len("") == 0

def test_string_equality():
    """Tests string equality."""
    assert "Python" == "Python"
    assert "python" != "Python" # Case sensitive

def test_string_contains():
    """Tests if a substring is present in a string."""
    assert "test" in "pytest is working"
    assert "foo" not in "bar baz"

# --- List Operations ---

def test_list_length():
    """Tests list length."""
    assert len([1, 2, 3]) == 3
    assert len([]) == 0

def test_list_contains():
    """Tests if an element is in a list."""
    assert 3 in [1, 2, 3, 4]
    assert 9 not in [1, 2, 3, 4]

def test_list_append():
    """Tests appending to a list."""
    my_list = [1]
    my_list.append(2)
    assert my_list == [1, 2]

def test_list_indexing():
    """Tests list indexing."""
    my_list = ['a', 'b', 'c']
    assert my_list[0] == 'a'
    assert my_list[2] == 'c'

# --- Dictionary Operations ---

def test_dict_access():
    """Tests dictionary access."""
    my_dict = {'key1': 'value1', 'key2': 2}
    assert my_dict['key1'] == 'value1'
    assert my_dict['key2'] == 2

def test_dict_keys():
    """Tests dictionary keys."""
    my_dict = {'a': 1, 'b': 2}
    assert 'a' in my_dict.keys()
    assert 'c' not in my_dict.keys()

# --- Exception Handling ---

def test_raises_type_error():
    """Tests that a TypeError is raised."""
    with pytest.raises(TypeError):
        "1" + 2 # This operation should raise a TypeError

def test_raises_zero_division_error():
    """Tests that a ZeroDivisionError is raised."""
    with pytest.raises(ZeroDivisionError):
        1 / 0 # This operation should raise a ZeroDivisionError

# --- Simple Function Test (to ensure function calls work) ---

def _my_simple_function(a, b):
    return a * b + 1

def test_simple_function_call():
    """Tests a simple helper function."""
    assert _my_simple_function(2, 3) == 7
    assert _my_simple_function(0, 10) == 1

# --- Parametrized Test (to show a common pytest feature) ---
# Requires pytest to be installed with its full features

@pytest.mark.parametrize("input_a, input_b, expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
    (10, -5, 5),
])
def test_parametrized_addition(input_a, input_b, expected):
    """Tests addition with multiple sets of inputs using parametrization."""
    assert input_a + input_b == expected

# --- Skipping a test (to show another pytest feature) ---

@pytest.mark.skip(reason="This test is intentionally skipped for demonstration.")
def test_skipped_test():
    """This test should be skipped when pytest runs."""
    assert False # This assertion will not be reached

# --- XFAIL (Expected to Fail) test (to show another pytest feature) ---

@pytest.mark.xfail(reason="This test is expected to fail currently.")
def test_xfail_test():
    """This test will show as 'xfailed' if it fails, or 'xpassed' if it passes."""
    assert 1 == 2 # This will cause the test to fail, marking it as xfailed
