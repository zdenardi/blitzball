-- pico-test

function test(title, f)
    local results_file = "test_results.txt"
    local function log(msg)
        printh(msg)
        printh(msg, results_file)
    end

    local passing_tests = 0
    local failing_tests = 0
    local desc = function(msg, f)
        log('\n*** ' .. msg .. ' ***\n')
        f()
    end
    local it = function(msg, f)
        log('   - it ' .. msg)
        local xs = { f() }
        for i = 1, #xs do
            if xs[i] == true then
                passing_tests += 1
                log('    PASS \n')
            else
                failing_tests += 1
                log('    FAIL \n')
            end
        end
    end
    printh("", results_file, true)
    log('Test "' .. title .. '"\n')
    f(desc, it)
    log('Finished! \n')
    log('Passing Tests: ' .. passing_tests .. '\n')
    log('Failing Tests: ' .. failing_tests .. '\n')
    log('\n')
end