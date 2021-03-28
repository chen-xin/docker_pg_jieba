Summary of bash scripting
==========================

## To get dirname without parents

${dir##*/}

## To update variable in sub shell

Changing global vars in sub shell won't affect it's value in global context, like:
```bash
global_var=asdf
foo()
{
    global_var=$(echo 4321)
}

echo something | grep some_pattern | \
    while read line
    do
        foo
        echo $global_var
    done
echo $global_var

# outputs:
# 4321
# asdf
```
[sub shell explination](https://stackoverflow.com/questions/23564995/how-to-modify-a-global-variable-within-a-function-in-bash?answertab=active#tab-top).

Finally I resigned to save that variable to a temporary file.

