-- pico-test
function test(title, f)
    local passing_tests = 0
    local failing_tests = 0
    local desc = function(msg, f)
        printh('*** ' .. msg .. ' ***\n')
        f()
    end
    local it = function(msg, f)
        printh('- it "' .. msg .. '"')
        local xs = { f() }
        for i = 1, #xs do
            if xs[i] == true then
                passing_tests += 1
                printh('    + Passed +  \n')
            else
                failing_tests += 1
                printh('    - Failed - \n')
            end
        end
    end
    printh('Test "' .. title .. '"\n')
    f(desc, it)
    printh('Finished! \n')
    printh('Passing Tests: ' .. passing_tests .. '\n')
    printh('Failing Tests: ' .. failing_tests .. '\n')
    printh('\n')
end