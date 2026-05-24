test(
    'Lib Functions', function(desc, it)
        desc(
            'get_index', function()
                local t = {
                    4, 2, 7, 8
                }
                it(
                    'should return the right number at index 3', function()
                        val = 7
                        exp_ans = 3
                        ans = get_index(t, val)
                        return ans == exp_ans
                    end
                )
            end
        )
    end
)