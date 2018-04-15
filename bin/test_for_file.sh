## This tests to see if a file exists and if it's permissions are correct or not.
## Then it attempts to assert that files permissions.
## Maybe add a test case to ensure that the file is critical or not.
function test_for_file() {
	if [ ! -f '$1' ]; then
		echo [Info] File $1 not found.
	else
		test_perm $1 $2 $3
	fi
}
