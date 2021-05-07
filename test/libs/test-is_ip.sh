#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/is_ip.sh"

# Auto launch function
test_isIp() {
  test_and_assert --fnc is_ip -psr -mb "$(printf "%-20s" "$2")" "$@"
}

test_isIp 0 0.0.0.0
test_isIp 0 08.08.08.08
test_isIp 0 255.255.255.255
test_isIp 1 256.256.256.256
test_isIp 1 a.b
test_isIp 1 0
test_isIp 0 4.2.0.32
test_isIp 1 4.2.0.324
test_isIp 1 a.32145.b.123
