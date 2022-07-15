#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_PACKS/cfg_file_mgmt.sh"

test_cfgFileMgmt() {
  test_and_assert --fnc cfg_load_file_to_vars -An +psr'|' "$@"
}

test_cfgLoadBlock() {
  test_and_assert --fnc cfg_load_block -An "$@"
}

WD_create

# Test error if file not found
test_cfgFileMgmt --with-errors "ERROR[cfg_load_file_to_vars]: File '/foobar' does not exist or cannot be read.|1" '/foobar'

# Classical tests
file1="$(WD_path)/mycfgfile1"
cat << EOF > "$file1"
# I am a comment
[sectionA]
thevarA=abc
thevarB=def
thevarC = foo
#thevarD=blub

[default]
thevarA=ghi
thevarB=jkl
EOF

# Test error no block found
test_cfgFileMgmt --with-errors "ERROR[cfg_load_file_to_vars]: No configuration found for [foo] in '$file1'.|1" "$file1:foo"

# Test error not empty
test_cfgFileMgmt --with-errors "ERROR[cfg_load_file_to_vars]: 'varA' not set (property 'thevarC').
ERROR[cfg_load_file_to_vars]: Loading '$file1' resulted in incomplete variable setting.|1" -ne "$file1" "varA=thevarC"

# Test error with custom logger
foo() {
  echo 'MYBAD' "$@"
}
test_cfgFileMgmt --with-errors "MYBAD No configuration found for [bar] in '$file1'.|1" --log foo "$file1:bar"


# From now on we have to call the method directly from this root to be able to set & display the variables

# Test default
cfg_load_file_to_vars "$file1" 'foo=thevarA' 'bar=thevarB'
assert 'ghi,jkl' "$foo,$bar"
unset foo bar

# Test normal, also testing if ignores comments properly
cfg_load_file_to_vars "$file1:sectionA" 'hello=thevarC' 'bar=thevarB' 'world=thevarD'
assert 'foo,,def' "$hello,$world,$bar"
unset foo bar

# Tests with types
file2content_path="$(WD_path)/mycfgfile2_content"
file2content="hellomoto"
echo "$file2content" > "$file2content_path"
file2="$(WD_path)/mycfgfile2"
cat << EOF > "$file2"
[withContent]
queen=$file2content_path

[default]
meow.kitty=cat $file2content_path
EOF

# Test file value
cfg_load_file_to_vars "$file2:withContent" 'mama=queen:file'
assert "$file2content" "$mama"
unset mama

# Test file as text
cfg_load_file_to_vars "$file2:withContent" 'elisabeth=queen'
assert "$file2content_path" "$elisabeth"
unset elisabeth

# Test command value
cfg_load_file_to_vars "$file2" 'milk=meow.kitty:cmd'
assert "$file2content" "$milk"
unset milk

# Test command as txt
cfg_load_file_to_vars "$file2" 'cptwhiskers=meow.kitty'
assert "cat $file2content_path" "$cptwhiskers"
unset cptwhiskers

# Tests load wildcards
file3="$(WD_path)/mycfgfile3"
cat << EOF > "$file3"
[A]
# I am an inside comment
the.var.A=abc
the.var.B=def
# And here's another one
the.var.C=foo
#the.var.D=blub
EOF

declare -A THE_VARS THE_VARS_EXPECTED
THE_VARS_EXPECTED[A]='abc'
THE_VARS_EXPECTED[B]='def'
THE_VARS_EXPECTED[C]='foo'
cfg_load_file_to_vars "$file3:A" 'THE_VARS=the.var.*'
assert -v 'THE_VARS_EXPECTED' 'THE_VARS'
unset THE_VARS THE_VARS_EXPECTED

# Tests specify type in config file
file4content_path="$(WD_path)/mycfgfile4_content"
file4content="idwq ow que wq aeewtewt
wqeu"
echo "$file4content" > "$file4content_path"
file4="$(WD_path)/mycfgfile4"
case4_cmd="newtpe"
cat << EOF > "$file4"
[default]
nt:cmd=echo $case4_cmd
some=var
some1:file=$file4content_path
EOF

cfg_load_file_to_vars "$file4" 'newtype=nt' 'HELLO=some1'
assert "$case4_cmd,$file4content" "${newtype},${HELLO}"
unset newtype HELLO

WD_delete
